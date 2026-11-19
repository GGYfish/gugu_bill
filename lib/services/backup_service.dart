import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../database/database.dart';
import 'backup_to_downloads.dart';

/// 数据备份 / 恢复服务
///
/// 负责把全部业务表（账单 / 负债 / 还款 / 账户 / 分类 / 银行 / 信贷机构）
/// 序列化为 JSON 导出 / 从 JSON 还原。
///
/// 设计要点：
/// - 导出：保留原始业务 ID（billId / liabilityId / accountId 等）以便完整恢复外键引用；
/// - 导入：先事务清空业务表，再按"基础表→引用表"的顺序插入，避免外键悬挂；
/// - 用户配置（自动记账开关 / token 等）不受导入影响，避免登录态被冲掉；
/// - 离线同步队列会被清空，因为导入相当于一次完整快照，无需再同步旧条目。
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// 备份格式版本号，迭代时递增
  static const int backupVersion = 1;

  /// 应用名（写入备份文件，便于用户识别）
  static const String appName = 'ai_bill';

  // ============================================================
  // 导出
  // ============================================================

  /// 把全部业务表导出为 JSON 文件，返回文件对象。
  /// 写入公共 Downloads 目录，用户可在文件管理器中直接查看。
  Future<File> exportToFile() async {
    final data = await _readAllTables();
    final payload = {
      'appName': appName,
      'version': backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': data,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${appName}_backup_$timestamp.json';

    final publicPath = await BackupToDownloads.saveToDownloads(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/json',
    );
    if (publicPath == null) {
      throw Exception('保存到 Downloads 目录失败');
    }
    debugPrint('[BackupService] 备份已写入: $publicPath');
    return File(publicPath);
  }

  Future<Map<String, dynamic>> _readAllTables() async {
    final categories = await _db.select(_db.localCategories).get();
    final banks = await _db.select(_db.localBanks).get();
    final credits = await _db.select(_db.localCreditInstitutions).get();
    final accounts = await _db.select(_db.localAccounts).get();
    final liabilities = await _db.select(_db.localLiabilities).get();
    final repays = await _db.select(_db.localLiabilityRepays).get();
    final bills = await _db.select(_db.localBills).get();

    return {
      'categories': categories.map(_categoryToJson).toList(),
      'banks': banks.map(_bankToJson).toList(),
      'creditInstitutions': credits.map(_creditToJson).toList(),
      'accounts': accounts.map(_accountToJson).toList(),
      'liabilities': liabilities.map(_liabilityToJson).toList(),
      'liabilityRepays': repays.map(_repayToJson).toList(),
      'bills': bills.map(_billToJson).toList(),
    };
  }

  // ============================================================
  // 导入
  // ============================================================

  /// 从 JSON 文件恢复数据。返回各类记录条数。
  ///
  /// 抛 FormatException 表示备份文件格式不兼容；
  /// 抛其他异常表示 IO/数据库错误。
  Future<BackupStats> importFromFile(File file) async {
    final content = await file.readAsString();
    final dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } catch (e) {
      throw const FormatException('备份文件不是合法的 JSON');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('备份文件结构错误');
    }
    if (decoded['appName'] != appName) {
      throw const FormatException('不是本应用的备份文件');
    }
    if (decoded['version'] != backupVersion) {
      throw FormatException(
        '备份版本不兼容（文件: ${decoded['version']}, 当前支持: $backupVersion）',
      );
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('备份文件缺少 data 字段');
    }

    int cats = 0, banks = 0, credits = 0, accs = 0;
    int liabs = 0, repays = 0, bills = 0;

    await _db.transaction(() async {
      // 1. 先清空全部业务表
      await _db.delete(_db.localBills).go();
      await _db.delete(_db.localLiabilityRepays).go();
      await _db.delete(_db.localLiabilities).go();
      await _db.delete(_db.localAccounts).go();
      await _db.delete(_db.localCategories).go();
      await _db.delete(_db.localBanks).go();
      await _db.delete(_db.localCreditInstitutions).go();

      // 2. 按"基础表 → 引用表"的顺序插入
      //    分类/银行/信贷机构 没有外键，最先
      for (final row in _asList(data['categories'])) {
        await _db.into(_db.localCategories).insert(
              _categoryFromJson(row),
              mode: InsertMode.insertOrReplace,
            );
        cats++;
      }
      for (final row in _asList(data['banks'])) {
        await _db.into(_db.localBanks).insert(
              _bankFromJson(row),
              mode: InsertMode.insertOrReplace,
            );
        banks++;
      }
      for (final row in _asList(data['creditInstitutions'])) {
        await _db.into(_db.localCreditInstitutions).insert(
              _creditFromJson(row),
              mode: InsertMode.insertOrReplace,
            );
        credits++;
      }
      //    账户依赖分类
      for (final row in _asList(data['accounts'])) {
        await _db.into(_db.localAccounts).insert(
              _accountFromJson(row),
              mode: InsertMode.insertOrReplace,
            );
        accs++;
      }
      //    负债依赖账户
      for (final row in _asList(data['liabilities'])) {
        await _db.into(_db.localLiabilities).insert(
              _liabilityFromJson(row),
              mode: InsertMode.insertOrReplace,
            );
        liabs++;
      }
      //    还款流水依赖负债 + 账户
      for (final row in _asList(data['liabilityRepays'])) {
        await _db.into(_db.localLiabilityRepays).insert(
              _repayFromJson(row),
              mode: InsertMode.insertOrReplace,
            );
        repays++;
      }
      //    账单依赖账户 / 分类 / 负债
      for (final row in _asList(data['bills'])) {
        await _db.into(_db.localBills).insert(
              _billFromJson(row),
              mode: InsertMode.insertOrReplace,
            );
        bills++;
      }
    });

    debugPrint(
      '[BackupService] 导入完成: cats=$cats banks=$banks credits=$credits '
      'accs=$accs liabs=$liabs repays=$repays bills=$bills',
    );

    return BackupStats(
      categories: cats,
      banks: banks,
      creditInstitutions: credits,
      accounts: accs,
      bills: bills,
      liabilities: liabs,
      liabilityRepays: repays,
    );
  }

  List<Map<String, dynamic>> _asList(dynamic v) {
    if (v == null) return const [];
    if (v is! List) return const [];
    return v.whereType<Map<String, dynamic>>().toList();
  }

  // ============================================================
  // JSON 序列化 / 反序列化
  // ============================================================

  // ---- categories ----
  Map<String, dynamic> _categoryToJson(LocalCategoriesData c) => {
        'categoryId': c.categoryId,
        'name': c.name,
        'icon': c.icon,
        'color': c.color,
        'type': c.type,
        'parentId': c.parentId,
        'sortOrder': c.sortOrder,
        'isEnabled': c.isEnabled,
        'createdAt': c.createdAt.toIso8601String(),
      };
  LocalCategoriesCompanion _categoryFromJson(Map<String, dynamic> j) =>
      LocalCategoriesCompanion(
        categoryId: Value(j['categoryId'] as String),
        name: Value(j['name'] as String),
        icon: Value((j['icon'] as String?) ?? 'category'),
        color: Value((j['color'] as String?) ?? '#7C4DFF'),
        type: Value(j['type'] as String),
        parentId: Value(j['parentId'] as String?),
        sortOrder: Value((j['sortOrder'] as int?) ?? 0),
        isEnabled: Value((j['isEnabled'] as bool?) ?? true),
        createdAt: Value(_parseDate(j['createdAt']) ?? DateTime.now()),
      );

  // ---- banks ----
  Map<String, dynamic> _bankToJson(LocalBanksData b) => {
        'bankId': b.bankId,
        'name': b.name,
        'icon': b.icon,
        'color': b.color,
        'code': b.code,
        'sortOrder': b.sortOrder,
        'isEnabled': b.isEnabled,
        'createdAt': b.createdAt.toIso8601String(),
      };
  LocalBanksCompanion _bankFromJson(Map<String, dynamic> j) => LocalBanksCompanion(
        bankId: Value(j['bankId'] as String),
        name: Value(j['name'] as String),
        icon: Value((j['icon'] as String?) ?? 'account_balance'),
        color: Value((j['color'] as String?) ?? '#1976D2'),
        code: Value(j['code'] as String?),
        sortOrder: Value((j['sortOrder'] as int?) ?? 0),
        isEnabled: Value((j['isEnabled'] as bool?) ?? true),
        createdAt: Value(_parseDate(j['createdAt']) ?? DateTime.now()),
      );

  // ---- credit institutions ----
  Map<String, dynamic> _creditToJson(LocalCreditInstitutionsData c) => {
        'institutionId': c.institutionId,
        'name': c.name,
        'type': c.type,
        'icon': c.icon,
        'color': c.color,
        'sortOrder': c.sortOrder,
        'isEnabled': c.isEnabled,
        'createdAt': c.createdAt.toIso8601String(),
      };
  LocalCreditInstitutionsCompanion _creditFromJson(Map<String, dynamic> j) =>
      LocalCreditInstitutionsCompanion(
        institutionId: Value(j['institutionId'] as String),
        name: Value(j['name'] as String),
        type: Value(j['type'] as String),
        icon: Value((j['icon'] as String?) ?? 'payments'),
        color: Value((j['color'] as String?) ?? '#FF5722'),
        sortOrder: Value((j['sortOrder'] as int?) ?? 0),
        isEnabled: Value((j['isEnabled'] as bool?) ?? true),
        createdAt: Value(_parseDate(j['createdAt']) ?? DateTime.now()),
      );

  // ---- accounts ----
  Map<String, dynamic> _accountToJson(LocalAccountsData a) => {
        'accountId': a.accountId,
        'name': a.name,
        'type': a.type,
        'icon': a.icon,
        'balance': a.balance,
        'color': a.color,
        'sortOrder': a.sortOrder,
        'isEnabled': a.isEnabled,
        'createdAt': a.createdAt.toIso8601String(),
        'updatedAt': a.updatedAt.toIso8601String(),
      };
  LocalAccountsCompanion _accountFromJson(Map<String, dynamic> j) =>
      LocalAccountsCompanion(
        accountId: Value(j['accountId'] as String),
        name: Value(j['name'] as String),
        type: Value(j['type'] as String),
        icon: Value((j['icon'] as String?) ?? 'wallet'),
        balance: Value((j['balance'] as num?)?.toDouble() ?? 0.0),
        color: Value((j['color'] as String?) ?? '#7C4DFF'),
        sortOrder: Value((j['sortOrder'] as int?) ?? 0),
        isEnabled: Value((j['isEnabled'] as bool?) ?? true),
        createdAt: Value(_parseDate(j['createdAt']) ?? DateTime.now()),
        updatedAt: Value(_parseDate(j['updatedAt']) ?? DateTime.now()),
      );

  // ---- liabilities ----
  Map<String, dynamic> _liabilityToJson(LocalLiabilitiesData l) => {
        'liabilityId': l.liabilityId,
        'name': l.name,
        'type': l.type,
        'accountId': l.accountId,
        'totalAmount': l.totalAmount,
        'repaidAmount': l.repaidAmount,
        'overdueAmount': l.overdueAmount,
        'dueDate': l.dueDate.toIso8601String(),
        'repayDate': l.repayDate?.toIso8601String(),
        'institution': l.institution,
        'loanDate': l.loanDate,
        'firstPaymentDate': l.firstPaymentDate?.toIso8601String(),
        'lastPaymentDate': l.lastPaymentDate?.toIso8601String(),
        'remark': l.remark,
        'status': l.status,
        'syncStatus': l.syncStatus,
        'createdAt': l.createdAt.toIso8601String(),
        'updatedAt': l.updatedAt.toIso8601String(),
      };
  LocalLiabilitiesCompanion _liabilityFromJson(Map<String, dynamic> j) =>
      LocalLiabilitiesCompanion(
        liabilityId: Value(j['liabilityId'] as String),
        name: Value(j['name'] as String),
        type: Value(j['type'] as String),
        accountId: Value(j['accountId'] as String),
        totalAmount: Value((j['totalAmount'] as num).toDouble()),
        repaidAmount: Value((j['repaidAmount'] as num?)?.toDouble() ?? 0.0),
        overdueAmount: Value((j['overdueAmount'] as num?)?.toDouble() ?? 0.0),
        dueDate: Value(_parseDate(j['dueDate']) ?? DateTime.now()),
        repayDate: Value(_parseDate(j['repayDate'])),
        institution: Value(j['institution'] as String?),
        loanDate: Value(j['loanDate'] as String?),
        firstPaymentDate: Value(_parseDate(j['firstPaymentDate'])),
        lastPaymentDate: Value(_parseDate(j['lastPaymentDate'])),
        remark: Value(j['remark'] as String?),
        status: Value((j['status'] as int?) ?? 0),
        syncStatus: Value((j['syncStatus'] as int?) ?? 0),
        createdAt: Value(_parseDate(j['createdAt']) ?? DateTime.now()),
        updatedAt: Value(_parseDate(j['updatedAt']) ?? DateTime.now()),
      );

  // ---- liability repays ----
  Map<String, dynamic> _repayToJson(LocalLiabilityRepaysData r) => {
        'repayId': r.repayId,
        'liabilityId': r.liabilityId,
        'amount': r.amount,
        'accountId': r.accountId,
        'repayTime': r.repayTime.toIso8601String(),
        'remark': r.remark,
        'syncStatus': r.syncStatus,
        'createdAt': r.createdAt.toIso8601String(),
      };
  LocalLiabilityRepaysCompanion _repayFromJson(Map<String, dynamic> j) =>
      LocalLiabilityRepaysCompanion(
        repayId: Value(j['repayId'] as String),
        liabilityId: Value(j['liabilityId'] as String),
        amount: Value((j['amount'] as num).toDouble()),
        accountId: Value(j['accountId'] as String),
        repayTime: Value(_parseDate(j['repayTime']) ?? DateTime.now()),
        remark: Value(j['remark'] as String?),
        syncStatus: Value((j['syncStatus'] as int?) ?? 0),
        createdAt: Value(_parseDate(j['createdAt']) ?? DateTime.now()),
      );

  // ---- bills ----
  Map<String, dynamic> _billToJson(LocalBillsData b) => {
        'billId': b.billId,
        'sourceHash': b.sourceHash,
        'type': b.type,
        'amount': b.amount,
        'categoryId': b.categoryId,
        'categoryName': b.categoryName,
        'accountId': b.accountId,
        'toAccountId': b.toAccountId,
        'liabilityId': b.liabilityId,
        'remark': b.remark,
        'billTime': b.billTime.toIso8601String(),
        'source': b.source,
        'confirmStatus': b.confirmStatus,
        'syncStatus': b.syncStatus,
        'createdAt': b.createdAt.toIso8601String(),
        'updatedAt': b.updatedAt.toIso8601String(),
      };
  LocalBillsCompanion _billFromJson(Map<String, dynamic> j) =>
      LocalBillsCompanion(
        billId: Value(j['billId'] as String),
        sourceHash: Value(j['sourceHash'] as String?),
        type: Value(j['type'] as String),
        amount: Value((j['amount'] as num).toDouble()),
        categoryId: Value(j['categoryId'] as String?),
        categoryName: Value(j['categoryName'] as String?),
        accountId: Value(j['accountId'] as String),
        toAccountId: Value(j['toAccountId'] as String?),
        liabilityId: Value(j['liabilityId'] as String?),
        remark: Value(j['remark'] as String?),
        billTime: Value(_parseDate(j['billTime']) ?? DateTime.now()),
        source: Value((j['source'] as String?) ?? 'manual'),
        confirmStatus: Value((j['confirmStatus'] as int?) ?? 1),
        syncStatus: Value((j['syncStatus'] as int?) ?? 0),
        createdAt: Value(_parseDate(j['createdAt']) ?? DateTime.now()),
        updatedAt: Value(_parseDate(j['updatedAt']) ?? DateTime.now()),
      );

  /// 容错地解析时间字段：可能是 ISO 字符串 / 时间戳毫秒 / null
  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v);
    }
    if (v is int) {
      // 毫秒时间戳
      return DateTime.fromMillisecondsSinceEpoch(v);
    }
    return null;
  }
}

/// 导入完成后的统计信息
class BackupStats {
  final int categories;
  final int banks;
  final int creditInstitutions;
  final int accounts;
  final int bills;
  final int liabilities;
  final int liabilityRepays;

  const BackupStats({
    required this.categories,
    required this.banks,
    required this.creditInstitutions,
    required this.accounts,
    required this.bills,
    required this.liabilities,
    required this.liabilityRepays,
  });

  int get total =>
      categories + banks + creditInstitutions + accounts + bills + liabilities + liabilityRepays;
}
