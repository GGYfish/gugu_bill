import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../utils/money.dart';

part 'database.g.dart';

// 离线同步队列
@DataClassName('OfflineSyncQueueData')
class OfflineSyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get syncTableName => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()();
  TextColumn get data => text()();
  IntColumn get status => integer().withDefault(const Constant(0))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

// 用户配置表
@DataClassName('LocalUserConfigData')
class LocalUserConfig extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get token => text().nullable()();
  BoolColumn get mockMode => boolean().withDefault(const Constant(true))();
  // 通知栏自动记账开关
  BoolColumn get notificationAutoRecordEnabled => boolean().withDefault(const Constant(false))();
  // 无障碍自动记账开关
  BoolColumn get accessibilityAutoRecordEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get smsListenEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get notificationListenEnabled => boolean().withDefault(const Constant(false))();
  RealColumn get monthlyBudget => real().withDefault(const Constant(0.0))();
  // 分类排序顺序（JSON: {"expense": ["id1","id2"], "income": ["id1"]}）
  TextColumn get categoryOrder => text().withDefault(const Constant('{}'))();
  // 分类使用次数（JSON: {"expense": {"food": 5, "shopping": 3}, "income": {"salary": 2}}）
  TextColumn get categoryUsage => text().withDefault(const Constant('{}'))();
  // ===== AI 配置 =====
  BoolColumn get aiEnabled => boolean().withDefault(const Constant(false))();
  /// 接口地址，如 https://api.openai.com/v1 或 https://api.deepseek.com/v1
  TextColumn get aiBaseUrl => text().withDefault(const Constant(''))();
  TextColumn get aiApiKey => text().withDefault(const Constant(''))();
  /// 模型名，如 gpt-4o-mini / deepseek-chat
  TextColumn get aiModel => text().withDefault(const Constant(''))();
  /// AI 性格：tease / gentle / serious / cute / coach
  TextColumn get aiPersonality =>
      text().withDefault(const Constant('tease'))();
  /// AI 对用户的称谓，如「老板」「宝」「小明」
  TextColumn get aiAppellation => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 账户表
@DataClassName('LocalAccountsData')
class LocalAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get accountId => text().unique()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get icon => text().withDefault(const Constant('wallet'))();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get color => text().withDefault(const Constant('#7C4DFF'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 账单表
@DataClassName('LocalBillsData')
class LocalBills extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get billId => text().unique()();
  TextColumn get sourceHash => text().nullable()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get categoryName => text().nullable()();
  TextColumn get accountId => text()();
  TextColumn get toAccountId => text().nullable()();
  // 关联负债ID（用于记一笔-还债时关联具体负债记录）
  TextColumn get liabilityId => text().nullable()();
  TextColumn get remark => text().nullable()();
  DateTimeColumn get billTime => dateTime()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  IntColumn get confirmStatus => integer().withDefault(const Constant(1))();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 负债主表
@DataClassName('LocalLiabilitiesData')
class LocalLiabilities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get liabilityId => text().unique()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get accountId => text()();
  RealColumn get totalAmount => real()();
  RealColumn get repaidAmount => real().withDefault(const Constant(0.0))();
  RealColumn get overdueAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get repayDate => dateTime().nullable()();
  // 房贷专用字段
  TextColumn get institution => text().nullable()();
  TextColumn get loanDate => text().nullable()();
  DateTimeColumn get firstPaymentDate => dateTime().nullable()();
  DateTimeColumn get lastPaymentDate => dateTime().nullable()();
  TextColumn get remark => text().nullable()();
  IntColumn get status => integer().withDefault(const Constant(0))();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// 负债还款流水
@DataClassName('LocalLiabilityRepaysData')
class LocalLiabilityRepays extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get repayId => text().unique()();
  TextColumn get liabilityId => text()();
  RealColumn get amount => real()();
  TextColumn get accountId => text()();
  DateTimeColumn get repayTime => dateTime()();
  TextColumn get remark => text().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 支出分类表（支持大分类和小分类层级）
@DataClassName('LocalCategoriesData')
class LocalCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get categoryId => text().unique()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('category'))();
  TextColumn get color => text().withDefault(const Constant('#7C4DFF'))();
  TextColumn get type => text()(); // expense, income
  // 父分类ID，null表示顶级大分类，有值表示小分类
  TextColumn get parentId => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 银行机构表
@DataClassName('LocalBanksData')
class LocalBanks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bankId => text().unique()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('account_balance'))();
  TextColumn get color => text().withDefault(const Constant('#1976D2'))();
  TextColumn get code => text().nullable()(); // 银行编码
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// 信贷机构表
@DataClassName('LocalCreditInstitutionsData')
class LocalCreditInstitutions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get institutionId => text().unique()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // loan, microloan, consumer
  TextColumn get icon => text().withDefault(const Constant('payments'))();
  TextColumn get color => text().withDefault(const Constant('#FF5722'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 咕咕鱼 AI 聊天历史
@DataClassName('LocalAiChatMessageData')
class LocalAiChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get isUser => boolean()();
  /// 消息正文（不可命名 text，会与 Table.text 冲突）
  TextColumn get content => text()();
  TextColumn get stickerId => text().nullable()();
  /// JSON 字符串数组，如 ["-¥18 餐饮"]
  TextColumn get billLinesJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isError => boolean().withDefault(const Constant(false))();
  /// 欢迎语等系统提示
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  OfflineSyncQueue,
  LocalUserConfig,
  LocalAccounts,
  LocalBills,
  LocalLiabilities,
  LocalLiabilityRepays,
  LocalCategories,
  LocalBanks,
  LocalCreditInstitutions,
  LocalAiChatMessages,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // 首次创建数据库时初始化默认数据
        try {
          await _initDefaultCategories();
        } catch (e) {
          debugPrint('初始化分类失败: $e');
        }
        try {
          await _initDefaultBanks();
        } catch (e) {
          debugPrint('初始化银行失败: $e');
        }
        try {
          await _initDefaultCreditInstitutions();
        } catch (e) {
          debugPrint('初始化信贷机构失败: $e');
        }
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // 从v1升级到v2：添加缺失的列
          await _addColumnIfNotExists('local_user_config', 'notification_auto_record_enabled', 'INTEGER NOT NULL DEFAULT 0');
          await _addColumnIfNotExists('local_user_config', 'accessibility_auto_record_enabled', 'INTEGER NOT NULL DEFAULT 0');
        }
        if (from < 3) {
          // 从v2升级到v3：添加房贷专用字段
          await _addColumnIfNotExists('local_liabilities', 'institution', 'TEXT');
          await _addColumnIfNotExists('local_liabilities', 'loan_date', 'TEXT');
          await _addColumnIfNotExists('local_liabilities', 'first_payment_date', 'INTEGER');
          await _addColumnIfNotExists('local_liabilities', 'last_payment_date', 'INTEGER');
        }
        if (from < 4) {
          // 从v3升级到v4：添加关联负债ID字段
          await _addColumnIfNotExists('local_bills', 'liability_id', 'TEXT');
        }
        if (from < 5) {
          // 从v4升级到v5：添加分类、银行、信贷机构表
          await m.createTable(localCategories);
          await m.createTable(localBanks);
          await m.createTable(localCreditInstitutions);
        }
        if (from < 6) {
          // 从v5升级到v6：添加父分类ID字段支持大分类小分类
          await _addColumnIfNotExists('local_categories', 'parent_id', 'TEXT');
        }
        if (from < 7) {
          // v7：补齐「自动记账」大分类（支出/收入）
          await ensureAutoRecordParentCategories();
        }
        if (from < 8) {
          // v8：AI 配置字段
          await _addColumnIfNotExists(
            'local_user_config',
            'ai_enabled',
            'INTEGER NOT NULL DEFAULT 0',
          );
          await _addColumnIfNotExists(
            'local_user_config',
            'ai_base_url',
            "TEXT NOT NULL DEFAULT ''",
          );
          await _addColumnIfNotExists(
            'local_user_config',
            'ai_api_key',
            "TEXT NOT NULL DEFAULT ''",
          );
          await _addColumnIfNotExists(
            'local_user_config',
            'ai_model',
            "TEXT NOT NULL DEFAULT ''",
          );
        }
        if (from < 9) {
          await _addColumnIfNotExists(
            'local_user_config',
            'ai_personality',
            "TEXT NOT NULL DEFAULT 'tease'",
          );
        }
        if (from < 10) {
          await m.createTable(localAiChatMessages);
        }
        if (from < 11) {
          await _addColumnIfNotExists(
            'local_user_config',
            'ai_appellation',
            "TEXT NOT NULL DEFAULT ''",
          );
        }

        // 确保分类数据存在（通用初始化逻辑）
        await _ensureCategoriesInitialized();
        await _ensureBanksInitialized();
        await _ensureCreditInstitutionsInitialized();
      },
    );
  }

  /// 确保分类数据已初始化（通用逻辑，处理所有版本升级）
  Future<void> _ensureCategoriesInitialized() async {
    final existingCats = await select(localCategories).get();
    if (existingCats.isEmpty) {
      // 没有任何分类数据，初始化
      await _initDefaultCategories();
    } else {
      // 检查是否有子分类（parentId 不为 null 的记录）
      final hasSubCategories = existingCats.any((c) => c.parentId != null);
      if (!hasSubCategories) {
        // 有数据但没有子分类结构，需要重新初始化
        await delete(localCategories).go();
        await _initDefaultCategories();
      } else {
        await ensureAutoRecordParentCategories();
      }
    }
  }

  /// 确保「自动记账」大分类存在（支出 / 收入各一个）
  Future<void> ensureAutoRecordParentCategories() async {
    Future<void> ensureOne({
      required String categoryId,
      required String type,
      required int sortOrder,
    }) async {
      final exists = await (select(localCategories)
            ..where((t) => t.categoryId.equals(categoryId)))
          .get();
      if (exists.isNotEmpty) return;
      await into(localCategories).insert(
        LocalCategoriesCompanion(
          categoryId: Value(categoryId),
          name: const Value('自动记账'),
          icon: const Value('auto_awesome'),
          color: const Value('#7C4DFF'),
          type: Value(type),
          parentId: const Value(null),
          sortOrder: Value(sortOrder),
        ),
      );
    }

    await ensureOne(
      categoryId: 'auto_record',
      type: 'expense',
      sortOrder: 98,
    );
    await ensureOne(
      categoryId: 'auto_record_income',
      type: 'income',
      sortOrder: 98,
    );
  }

  /// 解析自动记账小分类：挂在「自动记账」大类下，按来源名查找，没有则创建
  /// 返回 (categoryId, categoryName)
  Future<({String categoryId, String categoryName})> resolveAutoRecordSubCategory({
    required String sourceName,
    required String billType,
  }) async {
    await ensureAutoRecordParentCategories();

    final parentId =
        billType == 'income' ? 'auto_record_income' : 'auto_record';
    final name = sourceName.trim().isEmpty ? '未知来源' : sourceName.trim();

    final existing = await (select(localCategories)
          ..where((t) => t.parentId.equals(parentId) & t.name.equals(name)))
        .get();
    if (existing.isNotEmpty) {
      return (
        categoryId: existing.first.categoryId,
        categoryName: existing.first.name,
      );
    }

    final parent = await (select(localCategories)
          ..where((t) => t.categoryId.equals(parentId)))
        .getSingle();
    final siblings = await (select(localCategories)
          ..where((t) => t.parentId.equals(parentId)))
        .get();
    final sortOrder = siblings.length + 1;
    final categoryId =
        'auto_sub_${parentId}_${name.hashCode.toUnsigned(32).toRadixString(16)}';

    // 若 id 已存在（极端情况），直接复用
    final byId = await (select(localCategories)
          ..where((t) => t.categoryId.equals(categoryId)))
        .get();
    if (byId.isNotEmpty) {
      return (categoryId: byId.first.categoryId, categoryName: byId.first.name);
    }

    await into(localCategories).insert(
      LocalCategoriesCompanion(
        categoryId: Value(categoryId),
        name: Value(name),
        icon: Value(parent.icon),
        color: Value(parent.color),
        type: Value(parent.type),
        parentId: Value(parentId),
        sortOrder: Value(sortOrder),
      ),
    );

    return (categoryId: categoryId, categoryName: name);
  }

  /// 确保银行数据已初始化
  Future<void> _ensureBanksInitialized() async {
    final existingBanks = await select(localBanks).get();
    if (existingBanks.isEmpty) {
      await _initDefaultBanks();
    }
  }

  /// 确保信贷机构数据已初始化
  Future<void> _ensureCreditInstitutionsInitialized() async {
    final existingInst = await select(localCreditInstitutions).get();
    if (existingInst.isEmpty) {
      await _initDefaultCreditInstitutions();
    }
  }

  /// 初始化默认分类（包含大分类和小分类层级）
  Future<void> _initDefaultCategories() async {
    // 大分类（parentId 为 null）
    final parentCategories = [
      // 支出大分类
      LocalCategoriesCompanion(categoryId: const Value('food'), name: const Value('餐饮'), icon: const Value('restaurant'), color: const Value('#FF6B6B'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('shopping'), name: const Value('购物'), icon: const Value('shopping_bag'), color: const Value('#FFE66D'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(2)),
      LocalCategoriesCompanion(categoryId: const Value('transport'), name: const Value('交通'), icon: const Value('directions_car'), color: const Value('#4ECDC4'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(3)),
      LocalCategoriesCompanion(categoryId: const Value('consume'), name: const Value('消费'), icon: const Value('credit_card'), color: const Value('#A29BFE'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(4)),
      LocalCategoriesCompanion(categoryId: const Value('entertainment'), name: const Value('娱乐'), icon: const Value('movie'), color: const Value('#95E1D3'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(5)),
      LocalCategoriesCompanion(categoryId: const Value('transfer'), name: const Value('转账'), icon: const Value('swap_horiz'), color: const Value('#74B9FF'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(6)),
      LocalCategoriesCompanion(categoryId: const Value('medical'), name: const Value('医疗'), icon: const Value('local_hospital'), color: const Value('#AA96DA'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(7)),
      LocalCategoriesCompanion(categoryId: const Value('pet'), name: const Value('宠物'), icon: const Value('pets'), color: const Value('#FDA7DF'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(8)),
      LocalCategoriesCompanion(categoryId: const Value('communication'), name: const Value('通讯'), icon: const Value('phone_android'), color: const Value('#74B9FF'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(9)),
      LocalCategoriesCompanion(categoryId: const Value('housing'), name: const Value('住房'), icon: const Value('house'), color: const Value('#FDA7DF'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(10)),
      LocalCategoriesCompanion(categoryId: const Value('education'), name: const Value('教育'), icon: const Value('school'), color: const Value('#6C5CE7'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(11)),
      LocalCategoriesCompanion(categoryId: const Value('redpacket'), name: const Value('红包'), icon: const Value('card_giftcard'), color: const Value('#E1251B'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(12)),
      LocalCategoriesCompanion(categoryId: const Value('travel'), name: const Value('旅行'), icon: const Value('flight'), color: const Value('#00CEC9'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(13)),
      LocalCategoriesCompanion(categoryId: const Value('invest'), name: const Value('投资'), icon: const Value('trending_up'), color: const Value('#00B894'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(14)),
      LocalCategoriesCompanion(categoryId: const Value('lend'), name: const Value('借出'), icon: const Value('person_remove'), color: const Value('#F38181'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(15)),
      LocalCategoriesCompanion(categoryId: const Value('debt'), name: const Value('还债'), icon: const Value('credit_score'), color: const Value('#E74C3C'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(16)),
      LocalCategoriesCompanion(categoryId: const Value('beauty'), name: const Value('美容'), icon: const Value('spa'), color: const Value('#FD79A8'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(17)),
      // 自动记账大分类（监听到的来源作为其子分类）
      LocalCategoriesCompanion(categoryId: const Value('auto_record'), name: const Value('自动记账'), icon: const Value('auto_awesome'), color: const Value('#7C4DFF'), type: const Value('expense'), parentId: const Value(null), sortOrder: const Value(98)),
      // 收入大分类
      LocalCategoriesCompanion(categoryId: const Value('salary'), name: const Value('薪资'), icon: const Value('work'), color: const Value('#00B894'), type: const Value('income'), parentId: const Value(null), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('invest_income'), name: const Value('理财'), icon: const Value('trending_up'), color: const Value('#0984E3'), type: const Value('income'), parentId: const Value(null), sortOrder: const Value(2)),
      LocalCategoriesCompanion(categoryId: const Value('other_income'), name: const Value('其他收入'), icon: const Value('attach_money'), color: const Value('#FDCB6E'), type: const Value('income'), parentId: const Value(null), sortOrder: const Value(99)),
      LocalCategoriesCompanion(categoryId: const Value('auto_record_income'), name: const Value('自动记账'), icon: const Value('auto_awesome'), color: const Value('#7C4DFF'), type: const Value('income'), parentId: const Value(null), sortOrder: const Value(98)),
    ];

    // 小分类（parentId 指向父分类ID）
    final subCategories = [
      // 餐饮子分类
      LocalCategoriesCompanion(categoryId: const Value('food_oil_seasoning'), name: const Value('粮油调味'), icon: const Value('oil_barrel'), color: const Value('#FF6B6B'), type: const Value('expense'), parentId: const Value('food'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('food_coffee_tea'), name: const Value('咖啡奶茶'), icon: const Value('local_cafe'), color: const Value('#FF6B6B'), type: const Value('expense'), parentId: const Value('food'), sortOrder: const Value(2)),
      LocalCategoriesCompanion(categoryId: const Value('food_cigarette_wine'), name: const Value('烟酒茶叶'), icon: const Value('smoking_rooms'), color: const Value('#FF6B6B'), type: const Value('expense'), parentId: const Value('food'), sortOrder: const Value(3)),
      LocalCategoriesCompanion(categoryId: const Value('food_snack_fruit'), name: const Value('零食水果'), icon: const Value('eco'), color: const Value('#FF6B6B'), type: const Value('expense'), parentId: const Value('food'), sortOrder: const Value(4)),
      LocalCategoriesCompanion(categoryId: const Value('food_meals'), name: const Value('早中晚餐'), icon: const Value('restaurant'), color: const Value('#FF6B6B'), type: const Value('expense'), parentId: const Value('food'), sortOrder: const Value(5)),
      // 购物子分类
      LocalCategoriesCompanion(categoryId: const Value('shopping_furniture'), name: const Value('日常家具'), icon: const Value('chair'), color: const Value('#FFE66D'), type: const Value('expense'), parentId: const Value('shopping'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('shopping_baby'), name: const Value('母婴玩具'), icon: const Value('child_care'), color: const Value('#FFE66D'), type: const Value('expense'), parentId: const Value('shopping'), sortOrder: const Value(2)),
      LocalCategoriesCompanion(categoryId: const Value('shopping_appliance'), name: const Value('生活家电'), icon: const Value('kitchen'), color: const Value('#FFE66D'), type: const Value('expense'), parentId: const Value('shopping'), sortOrder: const Value(3)),
      LocalCategoriesCompanion(categoryId: const Value('shopping_beauty'), name: const Value('个护美妆'), icon: const Value('face'), color: const Value('#FFE66D'), type: const Value('expense'), parentId: const Value('shopping'), sortOrder: const Value(4)),
      LocalCategoriesCompanion(categoryId: const Value('shopping_clothes_sport'), name: const Value('服饰运动'), icon: const Value('checkroom'), color: const Value('#FFE66D'), type: const Value('expense'), parentId: const Value('shopping'), sortOrder: const Value(5)),
      // 交通子分类
      LocalCategoriesCompanion(categoryId: const Value('transport_fine'), name: const Value('罚款'), icon: const Value('gavel'), color: const Value('#4ECDC4'), type: const Value('expense'), parentId: const Value('transport'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('transport_toll'), name: const Value('高速费'), icon: const Value('toll'), color: const Value('#4ECDC4'), type: const Value('expense'), parentId: const Value('transport'), sortOrder: const Value(2)),
      LocalCategoriesCompanion(categoryId: const Value('transport_parking'), name: const Value('停车费'), icon: const Value('local_parking'), color: const Value('#4ECDC4'), type: const Value('expense'), parentId: const Value('transport'), sortOrder: const Value(3)),
      LocalCategoriesCompanion(categoryId: const Value('transport_fuel_charge'), name: const Value('加油充电'), icon: const Value('local_gas_station'), color: const Value('#4ECDC4'), type: const Value('expense'), parentId: const Value('transport'), sortOrder: const Value(4)),
      LocalCategoriesCompanion(categoryId: const Value('transport_maintenance'), name: const Value('修车保养'), icon: const Value('build'), color: const Value('#4ECDC4'), type: const Value('expense'), parentId: const Value('transport'), sortOrder: const Value(5)),
      LocalCategoriesCompanion(categoryId: const Value('transport_train_plane'), name: const Value('火车飞机'), icon: const Value('flight'), color: const Value('#4ECDC4'), type: const Value('expense'), parentId: const Value('transport'), sortOrder: const Value(6)),
      LocalCategoriesCompanion(categoryId: const Value('transport_taxi_rental'), name: const Value('打车租车'), icon: const Value('local_taxi'), color: const Value('#4ECDC4'), type: const Value('expense'), parentId: const Value('transport'), sortOrder: const Value(7)),
      LocalCategoriesCompanion(categoryId: const Value('transport_bus_subway'), name: const Value('公交地铁'), icon: const Value('directions_bus'), color: const Value('#4ECDC4'), type: const Value('expense'), parentId: const Value('transport'), sortOrder: const Value(8)),
      // 娱乐子分类
      LocalCategoriesCompanion(categoryId: const Value('entertainment_music'), name: const Value('音乐'), icon: const Value('music_note'), color: const Value('#95E1D3'), type: const Value('expense'), parentId: const Value('entertainment'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('entertainment_boardgame'), name: const Value('棋牌桌游'), icon: const Value('casino'), color: const Value('#95E1D3'), type: const Value('expense'), parentId: const Value('entertainment'), sortOrder: const Value(2)),
      LocalCategoriesCompanion(categoryId: const Value('entertainment_show'), name: const Value('演出'), icon: const Value('theater_comedy'), color: const Value('#95E1D3'), type: const Value('expense'), parentId: const Value('entertainment'), sortOrder: const Value(3)),
      LocalCategoriesCompanion(categoryId: const Value('entertainment_massage'), name: const Value('足浴按摩'), icon: const Value('spa'), color: const Value('#95E1D3'), type: const Value('expense'), parentId: const Value('entertainment'), sortOrder: const Value(4)),
      LocalCategoriesCompanion(categoryId: const Value('entertainment_sports'), name: const Value('运动健身'), icon: const Value('fitness_center'), color: const Value('#95E1D3'), type: const Value('expense'), parentId: const Value('entertainment'), sortOrder: const Value(5)),
      LocalCategoriesCompanion(categoryId: const Value('entertainment_movie'), name: const Value('电影'), icon: const Value('movie'), color: const Value('#95E1D3'), type: const Value('expense'), parentId: const Value('entertainment'), sortOrder: const Value(6)),
      LocalCategoriesCompanion(categoryId: const Value('entertainment_dating'), name: const Value('约会'), icon: const Value('favorite'), color: const Value('#95E1D3'), type: const Value('expense'), parentId: const Value('entertainment'), sortOrder: const Value(7)),
      LocalCategoriesCompanion(categoryId: const Value('entertainment_game'), name: const Value('电子游戏'), icon: const Value('sports_esports'), color: const Value('#95E1D3'), type: const Value('expense'), parentId: const Value('entertainment'), sortOrder: const Value(8)),
      // 医疗子分类
      LocalCategoriesCompanion(categoryId: const Value('medical_pharmacy'), name: const Value('药店买药'), icon: const Value('local_pharmacy'), color: const Value('#AA96DA'), type: const Value('expense'), parentId: const Value('medical'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('medical_hospital'), name: const Value('医院'), icon: const Value('local_hospital'), color: const Value('#AA96DA'), type: const Value('expense'), parentId: const Value('medical'), sortOrder: const Value(2)),
      // 宠物子分类
      LocalCategoriesCompanion(categoryId: const Value('pet_food'), name: const Value('猫粮狗粮'), icon: const Value('pets'), color: const Value('#FDA7DF'), type: const Value('expense'), parentId: const Value('pet'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('pet_toy'), name: const Value('玩具'), icon: const Value('toys'), color: const Value('#FDA7DF'), type: const Value('expense'), parentId: const Value('pet'), sortOrder: const Value(2)),
      // 通讯子分类
      LocalCategoriesCompanion(categoryId: const Value('communication_phone'), name: const Value('话费'), icon: const Value('phone'), color: const Value('#74B9FF'), type: const Value('expense'), parentId: const Value('communication'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('communication_net'), name: const Value('网费'), icon: const Value('wifi'), color: const Value('#74B9FF'), type: const Value('expense'), parentId: const Value('communication'), sortOrder: const Value(2)),
      // 住房子分类
      LocalCategoriesCompanion(categoryId: const Value('housing_repair_clean'), name: const Value('维修清洁'), icon: const Value('cleaning_services'), color: const Value('#FDA7DF'), type: const Value('expense'), parentId: const Value('housing'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('housing_utility'), name: const Value('水电燃气'), icon: const Value('water_drop'), color: const Value('#FDA7DF'), type: const Value('expense'), parentId: const Value('housing'), sortOrder: const Value(2)),
      LocalCategoriesCompanion(categoryId: const Value('housing_rent_property'), name: const Value('租房物业'), icon: const Value('house'), color: const Value('#FDA7DF'), type: const Value('expense'), parentId: const Value('housing'), sortOrder: const Value(3)),
      // 教育子分类
      LocalCategoriesCompanion(categoryId: const Value('education_book'), name: const Value('书报杂志'), icon: const Value('menu_book'), color: const Value('#6C5CE7'), type: const Value('expense'), parentId: const Value('education'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('education_tutor'), name: const Value('家教补习'), icon: const Value('school'), color: const Value('#6C5CE7'), type: const Value('expense'), parentId: const Value('education'), sortOrder: const Value(2)),
      LocalCategoriesCompanion(categoryId: const Value('education_exam'), name: const Value('培训考试'), icon: const Value('quiz'), color: const Value('#6C5CE7'), type: const Value('expense'), parentId: const Value('education'), sortOrder: const Value(3)),
      LocalCategoriesCompanion(categoryId: const Value('education_tuition'), name: const Value('学费'), icon: const Value('payments'), color: const Value('#6C5CE7'), type: const Value('expense'), parentId: const Value('education'), sortOrder: const Value(4)),
      // 红包子分类
      LocalCategoriesCompanion(categoryId: const Value('redpacket_lucky'), name: const Value('压岁钱'), icon: const Value('card_giftcard'), color: const Value('#E1251B'), type: const Value('expense'), parentId: const Value('redpacket'), sortOrder: const Value(1)),
      // 旅行子分类
      LocalCategoriesCompanion(categoryId: const Value('travel_ticket'), name: const Value('经典门票'), icon: const Value('confirmation_number'), color: const Value('#00CEC9'), type: const Value('expense'), parentId: const Value('travel'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('travel_food'), name: const Value('美食特产'), icon: const Value('restaurant'), color: const Value('#00CEC9'), type: const Value('expense'), parentId: const Value('travel'), sortOrder: const Value(2)),
      LocalCategoriesCompanion(categoryId: const Value('travel_hotel'), name: const Value('酒店住宿'), icon: const Value('hotel'), color: const Value('#00CEC9'), type: const Value('expense'), parentId: const Value('travel'), sortOrder: const Value(3)),
      LocalCategoriesCompanion(categoryId: const Value('travel_transport'), name: const Value('旅行交通'), icon: const Value('flight'), color: const Value('#00CEC9'), type: const Value('expense'), parentId: const Value('travel'), sortOrder: const Value(4)),
      // 投资子分类
      LocalCategoriesCompanion(categoryId: const Value('invest_gold'), name: const Value('黄金'), icon: const Value('monetization_on'), color: const Value('#00B894'), type: const Value('expense'), parentId: const Value('invest'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('invest_insurance'), name: const Value('保险'), icon: const Value('security'), color: const Value('#00B894'), type: const Value('expense'), parentId: const Value('invest'), sortOrder: const Value(2)),
      LocalCategoriesCompanion(categoryId: const Value('invest_stock'), name: const Value('股票'), icon: const Value('show_chart'), color: const Value('#00B894'), type: const Value('expense'), parentId: const Value('invest'), sortOrder: const Value(3)),
      LocalCategoriesCompanion(categoryId: const Value('invest_fund'), name: const Value('基金'), icon: const Value('account_balance'), color: const Value('#00B894'), type: const Value('expense'), parentId: const Value('invest'), sortOrder: const Value(4)),
      // 薪资子分类（收入）
      LocalCategoriesCompanion(categoryId: const Value('salary_wage'), name: const Value('工资'), icon: const Value('payments'), color: const Value('#00B894'), type: const Value('income'), parentId: const Value('salary'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('salary_bonus'), name: const Value('奖金'), icon: const Value('card_giftcard'), color: const Value('#00B894'), type: const Value('income'), parentId: const Value('salary'), sortOrder: const Value(2)),
      LocalCategoriesCompanion(categoryId: const Value('salary_parttime'), name: const Value('兼职'), icon: const Value('work'), color: const Value('#00B894'), type: const Value('income'), parentId: const Value('salary'), sortOrder: const Value(3)),
      // 理财子分类（收入）
      LocalCategoriesCompanion(categoryId: const Value('invest_income_interest'), name: const Value('利息'), icon: const Value('account_balance_wallet'), color: const Value('#0984E3'), type: const Value('income'), parentId: const Value('invest_income'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('invest_income_dividend'), name: const Value('分红'), icon: const Value('payments'), color: const Value('#0984E3'), type: const Value('income'), parentId: const Value('invest_income'), sortOrder: const Value(2)),
      // 其他收入子分类
      LocalCategoriesCompanion(categoryId: const Value('other_income_redpacket'), name: const Value('红包'), icon: const Value('card_giftcard'), color: const Value('#FDCB6E'), type: const Value('income'), parentId: const Value('other_income'), sortOrder: const Value(1)),
      LocalCategoriesCompanion(categoryId: const Value('other_income_receive'), name: const Value('收款'), icon: const Value('request_quote'), color: const Value('#FDCB6E'), type: const Value('income'), parentId: const Value('other_income'), sortOrder: const Value(2)),
    ];

    // 先插入所有分类
    for (final cat in parentCategories) {
      await into(localCategories).insert(cat);
    }
    for (final cat in subCategories) {
      await into(localCategories).insert(cat);
    }
  }

  /// 初始化默认银行
  Future<void> _initDefaultBanks() async {
    final defaultBanks = [
      // ===== 国有大型银行 =====
      LocalBanksCompanion(bankId: const Value('ICBC'), name: const Value('工商银行'), icon: const Value('account_balance'), color: const Value('#C41230'), code: const Value('ICBC')),
      LocalBanksCompanion(bankId: const Value('ABC'), name: const Value('农业银行'), icon: const Value('account_balance'), color: const Value('#138D26'), code: const Value('ABC')),
      LocalBanksCompanion(bankId: const Value('BOC'), name: const Value('中国银行'), icon: const Value('account_balance'), color: const Value('#D4A017'), code: const Value('BOC')),
      LocalBanksCompanion(bankId: const Value('CCB'), name: const Value('建设银行'), icon: const Value('account_balance'), color: const Value('#003087'), code: const Value('CCB')),
      LocalBanksCompanion(bankId: const Value('COMM'), name: const Value('交通银行'), icon: const Value('account_balance'), color: const Value('#003F8A'), code: const Value('COMM')),
      LocalBanksCompanion(bankId: const Value('PSBC'), name: const Value('邮储银行'), icon: const Value('account_balance'), color: const Value('#00865A'), code: const Value('PSBC')),
      
      // ===== 股份制商业银行 =====
      LocalBanksCompanion(bankId: const Value('CMB'), name: const Value('招商银行'), icon: const Value('account_balance'), color: const Value('#E31837'), code: const Value('CMB')),
      LocalBanksCompanion(bankId: const Value('CITIC'), name: const Value('中信银行'), icon: const Value('account_balance'), color: const Value('#C41230'), code: const Value('CITIC')),
      LocalBanksCompanion(bankId: const Value('CEB'), name: const Value('光大银行'), icon: const Value('account_balance'), color: const Value('#FF6600'), code: const Value('CEB')),
      LocalBanksCompanion(bankId: const Value('CMBC'), name: const Value('民生银行'), icon: const Value('account_balance'), color: const Value('#003A70'), code: const Value('CMBC')),
      LocalBanksCompanion(bankId: const Value('PAB'), name: const Value('平安银行'), icon: const Value('account_balance'), color: const Value('#E85D04'), code: const Value('PAB')),
      LocalBanksCompanion(bankId: const Value('SPDB'), name: const Value('浦发银行'), icon: const Value('account_balance'), color: const Value('#00347A'), code: const Value('SPDB')),
      LocalBanksCompanion(bankId: const Value('CIB'), name: const Value('兴业银行'), icon: const Value('account_balance'), color: const Value('#003087'), code: const Value('CIB')),
      LocalBanksCompanion(bankId: const Value('HXB'), name: const Value('华夏银行'), icon: const Value('account_balance'), color: const Value('#E85D04'), code: const Value('HXB')),
      LocalBanksCompanion(bankId: const Value('CGB'), name: const Value('广发银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('CGB')),
      LocalBanksCompanion(bankId: const Value('ZSB'), name: const Value('浙商银行'), icon: const Value('account_balance'), color: const Value('#C8102E'), code: const Value('ZSB')),
      LocalBanksCompanion(bankId: const Value('BOH'), name: const Value('渤海银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('BOH')),
      LocalBanksCompanion(bankId: const Value('HFB'), name: const Value('恒丰银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('HFB')),
      
      // ===== 城市商业银行 =====
      LocalBanksCompanion(bankId: const Value('BJB'), name: const Value('北京银行'), icon: const Value('account_balance'), color: const Value('#1E6BB8'), code: const Value('BJB')),
      LocalBanksCompanion(bankId: const Value('SHB'), name: const Value('上海银行'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('SHB')),
      LocalBanksCompanion(bankId: const Value('JSB'), name: const Value('江苏银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('JSB')),
      LocalBanksCompanion(bankId: const Value('NJCB'), name: const Value('南京银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('NJCB')),
      LocalBanksCompanion(bankId: const Value('HZB'), name: const Value('杭州银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('HZB')),
      LocalBanksCompanion(bankId: const Value('NBCB'), name: const Value('宁波银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('NBCB')),
      LocalBanksCompanion(bankId: const Value('HSB'), name: const Value('徽商银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('HSB')),
      LocalBanksCompanion(bankId: const Value('CSRCB'), name: const Value('成都银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('CSRCB')),
      LocalBanksCompanion(bankId: const Value('CQB'), name: const Value('重庆银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('CQB')),
      LocalBanksCompanion(bankId: const Value('ZZB'), name: const Value('郑州银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('ZZB')),
      LocalBanksCompanion(bankId: const Value('JNB'), name: const Value('济宁银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('JNB')),
      LocalBanksCompanion(bankId: const Value('LYB'), name: const Value('兰州银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('LYB')),
      LocalBanksCompanion(bankId: const Value('XMB'), name: const Value('厦门银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('XMB')),
      LocalBanksCompanion(bankId: const Value('SZSB'), name: const Value('苏州银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('SZSB')),
      LocalBanksCompanion(bankId: const Value('DLB'), name: const Value('大连银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('DLB')),
      LocalBanksCompanion(bankId: const Value('WHB'), name: const Value('武汉银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('WHB')),
      LocalBanksCompanion(bankId: const Value('TJB'), name: const Value('天津银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('TJB')),
      LocalBanksCompanion(bankId: const Value('NJB'), name: const Value('宁波通商'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('NJB')),
      LocalBanksCompanion(bankId: const Value('QDB'), name: const Value('青岛银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('QDB')),
      LocalBanksCompanion(bankId: const Value('CZB'), name: const Value('长沙银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('CZB')),
      LocalBanksCompanion(bankId: const Value('GZB'), name: const Value('贵州银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('GZB')),
      LocalBanksCompanion(bankId: const Value('LZCB'), name: const Value('柳州银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('LZCB')),
      LocalBanksCompanion(bankId: const Value('HNB'), name: const Value('海南银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('HNB')),
      LocalBanksCompanion(bankId: const Value('GLB'), name: const Value('桂林银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('GLB')),
      LocalBanksCompanion(bankId: const Value('JZB'), name: const Value('江西银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('JZB')),
      LocalBanksCompanion(bankId: const Value('HEBB'), name: const Value('河北银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('HEBB')),
      LocalBanksCompanion(bankId: const Value('URB'), name: const Value('吉林银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('URB')),
      LocalBanksCompanion(bankId: const Value('LZSB'), name: const Value('临商银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('LZSB')),
      LocalBanksCompanion(bankId: const Value('ZZSB'), name: const Value('枣庄银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('ZZSB')),
      LocalBanksCompanion(bankId: const Value('DYB'), name: const Value('东营银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('DYB')),
      LocalBanksCompanion(bankId: const Value('YTB'), name: const Value('烟台银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('YTB')),
      LocalBanksCompanion(bankId: const Value('WFB'), name: const Value('潍坊银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('WFB')),
      LocalBanksCompanion(bankId: const Value('JZB2'), name: const Value('济宁银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('JZB2')),
      LocalBanksCompanion(bankId: const Value('LFB'), name: const Value('莱商银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('LFB')),
      LocalBanksCompanion(bankId: const Value('ZYB'), name: const Value('泰安银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('ZYB')),
      LocalBanksCompanion(bankId: const Value('ZBB'), name: const Value('齐商银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('ZBB')),
      LocalBanksCompanion(bankId: const Value('LCB'), name: const Value('聊城银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('LCB')),
      LocalBanksCompanion(bankId: const Value('BYB'), name: const Value('临沂银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('BYB')),
      LocalBanksCompanion(bankId: const Value('BHB'), name: const Value('滨州银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('BHB')),
      LocalBanksCompanion(bankId: const Value('ZCB'), name: const Value('菏泽银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('ZCB')),
      
      // ===== 农村商业银行 =====
      LocalBanksCompanion(bankId: const Value('BJRCB'), name: const Value('北京农商'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('BJRCB')),
      LocalBanksCompanion(bankId: const Value('SHRCB'), name: const Value('上海农商'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('SHRCB')),
      LocalBanksCompanion(bankId: const Value('GDNYB'), name: const Value('广州农商'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('GDNYB')),
      LocalBanksCompanion(bankId: const Value('SZRCB'), name: const Value('深圳农商'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('SZRCB')),
      LocalBanksCompanion(bankId: const Value('J SRC B'), name: const Value('江苏农商'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('JSRCB')),
      LocalBanksCompanion(bankId: const Value('ZJRCB'), name: const Value('浙江农商'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('ZJRCB')),
      LocalBanksCompanion(bankId: const Value('AHRCB'), name: const Value('安徽农金'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('AHRCB')),
      LocalBanksCompanion(bankId: const Value('SDRCB'), name: const Value('山东农信'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('SDRCB')),
      
      // ===== 互联网银行 =====
      LocalBanksCompanion(bankId: const Value('MYBANK'), name: const Value('网商银行'), icon: const Value('account_balance'), color: const Value('#1677FF'), code: const Value('MYBANK')),
      LocalBanksCompanion(bankId: const Value('WEBANK'), name: const Value('微众银行'), icon: const Value('account_balance'), color: const Value('#07C160'), code: const Value('WEBANK')),
      LocalBanksCompanion(bankId: const Value('XWB'), name: const Value('新网银行'), icon: const Value('account_balance'), color: const Value('#1677FF'), code: const Value('XWB')),
      LocalBanksCompanion(bankId: const Value('ZBANK'), name: const Value('众邦银行'), icon: const Value('account_balance'), color: const Value('#FF6600'), code: const Value('ZBANK')),
      LocalBanksCompanion(bankId: const Value('XKB'), name: const Value('新快银行'), icon: const Value('account_balance'), color: const Value('#1677FF'), code: const Value('XKB')),
      LocalBanksCompanion(bankId: const Value('YSB'), name: const Value('裕民银行'), icon: const Value('account_balance'), color: const Value('#1677FF'), code: const Value('YSB')),
      LocalBanksCompanion(bankId: const Value('ALB'), name: const Value('中关村银行'), icon: const Value('account_balance'), color: const Value('#1677FF'), code: const Value('ALB')),
      LocalBanksCompanion(bankId: const Value('WLB'), name: const Value('武汉众邦'), icon: const Value('account_balance'), color: const Value('#FF6600'), code: const Value('WLB')),
      
      // ===== 外资银行 =====
      LocalBanksCompanion(bankId: const Value('HSBC'), name: const Value('汇丰银行'), icon: const Value('account_balance'), color: const Value('#E31837'), code: const Value('HSBC')),
      LocalBanksCompanion(bankId: const Value('SCB'), name: const Value('渣打银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('SCB')),
      LocalBanksCompanion(bankId: const Value('CITI'), name: const Value('花旗银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('CITI')),
      LocalBanksCompanion(bankId: const Value('BEA'), name: const Value('东亚银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('BEA')),
      LocalBanksCompanion(bankId: const Value('OCBC'), name: const Value('华侨银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('OCBC')),
      LocalBanksCompanion(bankId: const Value('UOB'), name: const Value('大华银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('UOB')),
      LocalBanksCompanion(bankId: const Value('DBS'), name: const Value('星展银行'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('DBS')),
      LocalBanksCompanion(bankId: const Value('MIZUHO'), name: const Value('瑞穗银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('MIZUHO')),
      LocalBanksCompanion(bankId: const Value('SMBC'), name: const Value('三井住友'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('SMBC')),
      LocalBanksCompanion(bankId: const Value('BNP'), name: const Value('法巴银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('BNP')),
      LocalBanksCompanion(bankId: const Value('DB'), name: const Value('德意志银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('DB')),
      
      // ===== 其他常见银行 =====
      LocalBanksCompanion(bankId: const Value('CZBANK'), name: const Value('华瑞银行'), icon: const Value('account_balance'), color: const Value('#1677FF'), code: const Value('CZBANK')),
      LocalBanksCompanion(bankId: const Value('FUB'), name: const Value('富滇银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('FUB')),
      LocalBanksCompanion(bankId: const Value('YNRB'), name: const Value('云南农信'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('YNRB')),
      LocalBanksCompanion(bankId: const Value('SXCB'), name: const Value('陕西信合'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('SXCB')),
      LocalBanksCompanion(bankId: const Value('NXB'), name: const Value('宁夏银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('NXB')),
      LocalBanksCompanion(bankId: const Value('XJB'), name: const Value('新疆银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('XJB')),
      LocalBanksCompanion(bankId: const Value('HLJ'), name: const Value('龙江银行'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('HLJ')),
      LocalBanksCompanion(bankId: const Value('JLB'), name: const Value('吉林银行'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('JLB')),
      LocalBanksCompanion(bankId: const Value('CCB2'), name: const Value('稠州银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('CCB2')),
      LocalBanksCompanion(bankId: const Value('QLB'), name: const Value('齐鲁银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('QLB')),
      LocalBanksCompanion(bankId: const Value('HKB'), name: const Value('汉口银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('HKB')),
      LocalBanksCompanion(bankId: const Value('NCB'), name: const Value('宁波银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('NCB')),
      LocalBanksCompanion(bankId: const Value('GDB'), name: const Value('贵安银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('GDB')),
      LocalBanksCompanion(bankId: const Value('SJB'), name: const Value('盛京银行'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('SJB')),
      LocalBanksCompanion(bankId: const Value('YLCB'), name: const Value('营口银行'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('YLCB')),
      LocalBanksCompanion(bankId: const Value('ZYCB'), name: const Value('阜新银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('ZYCB')),
      LocalBanksCompanion(bankId: const Value('TLB'), name: const Value('辽阳银行'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('TLB')),
      LocalBanksCompanion(bankId: const Value('ASB'), name: const Value('鞍山银行'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('ASB')),
      LocalBanksCompanion(bankId: const Value('FXB'), name: const Value('抚顺银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('FXB')),
      LocalBanksCompanion(bankId: const Value('BDCB'), name: const Value('本溪银行'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('BDCB')),
      LocalBanksCompanion(bankId: const Value('DDD'), name: const Value('丹东银行'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('DDD')),
      LocalBanksCompanion(bankId: const Value('YYB'), name: const Value('营口银行'), icon: const Value('account_balance'), color: const Value('#E60012'), code: const Value('YYB')),
      LocalBanksCompanion(bankId: const Value('LXB'), name: const Value('廊坊银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('LXB')),
      LocalBanksCompanion(bankId: const Value('ZHB'), name: const Value('珠海银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('ZHB')),
      LocalBanksCompanion(bankId: const Value('NNB'), name: const Value('南海银行'), icon: const Value('account_balance'), color: const Value('#0066CC'), code: const Value('NNB')),
      LocalBanksCompanion(bankId: const Value('WHRCB'), name: const Value('武汉农商'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('WHRCB')),
      LocalBanksCompanion(bankId: const Value('CDRCB'), name: const Value('成都农商'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('CDRCB')),
      LocalBanksCompanion(bankId: const Value('TJRCB'), name: const Value('天津农商'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('TJRCB')),
      LocalBanksCompanion(bankId: const Value('CQRCB'), name: const Value('重庆农商'), icon: const Value('account_balance'), color: const Value('#0066B3'), code: const Value('CQRCB')),
    ];

    for (final bank in defaultBanks) {
      await into(localBanks).insert(bank);
    }
  }

  /// 初始化默认信贷机构
  Future<void> _initDefaultCreditInstitutions() async {
    final defaultInstitutions = [
      // ===== 互联网信贷平台 =====
      LocalCreditInstitutionsCompanion(institutionId: const Value('alipay_hb'), name: const Value('花呗'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#1677FF')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('alipay_jb'), name: const Value('支付宝借呗'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#1677FF')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('wechat_wld'), name: const Value('微信微粒贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#07C160')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('jd_jt'), name: const Value('京东金条'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#E1251B')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('jd_baitiao'), name: const Value('京东白条'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#E1251B')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('meituan_hb'), name: const Value('美团月付'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#FFD100')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('meituan_dai'), name: const Value('美团生意贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#FFD100')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('duxiaoman'), name: const Value('度小满'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#2196F3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('weilidai'), name: const Value('微粒贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#07C160')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('360_jietiao'), name: const Value('360借条'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#2196F3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('yiqijie'), name: const Value('安逸花'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#FF5722')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('lianxiangdai'), name: const Value('分期乐'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#E91E63')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('guangdasheng'), name: const Value('光大省息'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#FF6600')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('tianmao_huabei'), name: const Value('天猫花呗'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#FF5000')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('dianping_xinyong'), name: const Value('大众点评信用付'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#FF6600')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('douyin_xin'), name: const Value('抖音月付'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#000000')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('pinduoduo_qiakuan'), name: const Value('拼多多钱包'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#E1251B')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('kuaiqian'), name: const Value('快钱'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#2196F3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('soumidai'), name: const Value('搜狗借钱'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#FF5722')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('wangxin'), name: const Value('放心借'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#4CAF50')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('xiaomi_dai'), name: const Value('小米随星借'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#FF6900')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('oppo_finup'), name: const Value('oppo钱包'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#00FF00')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('vivo_dai'), name: const Value('vivo金融'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#2196F3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('huawei_dai'), name: const Value('华为随行贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#E41B17')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('qunar_bei'), name: const Value('去哪儿信用购'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#00BFFF')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('ctrip_qian'), name: const Value('携程拿去花'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#FF5000')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('meituan_xinyong'), name: const Value('美团信用支付'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#FFD100')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('yinlian_e'), name: const Value('银联云闪付'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#E41B17')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('sina_dai'), name: const Value('新浪借钱'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#FF6900')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('baidu_youhui'), name: const Value('百度优选'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#2932E1')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('tencent_lijie'), name: const Value('腾讯理财通'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#07C160')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('zhuanzhuan_xin'), name: const Value('转转信用'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#4CAF50')),
      
      // ===== 消费金融公司 =====
      LocalCreditInstitutionsCompanion(institutionId: const Value('ant_fin'), name: const Value('蚂蚁消费金融'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#1677FF')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('jd_fin'), name: const Value('京东消费金融'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#E1251B')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('wechat_fin'), name: const Value('微众消费金融'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#07C160')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('zhaolian'), name: const Value('招联消费金融'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#E31837')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('xianxia'), name: const Value('马上消费金融'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#FF5722')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('rongsheng'), name: const Value('马上消费'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#FF5722')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('pingan_fin'), name: const Value('平安消费金融'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#E85D04')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('shanghai_fin'), name: const Value('上海银行消费金融'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#0066B3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('yicheng'), name: const Value('宜人贷'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#4CAF50')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('renrendai'), name: const Value('人人贷'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#2196F3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('ppdai'), name: const Value('拍拍贷'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#FF5722')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('youxin'), name: const Value('友信普惠'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#2196F3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('le360'), name: const Value('360贷款导航'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#2196F3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('zhongshen'), name: const Value('中审信贷'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#607D8B')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('lufax'), name: const Value('陆金所'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#1976D2')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('wacai'), name: const Value('挖财信用卡管家'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#FF5722')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('juxinli'), name: const Value('聚信立'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#607D8B')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('tianyan'), name: const Value('天眼查贷款'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#2196F3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('xiaoniu'), name: const Value('小牛普惠'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#607D8B')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('puyou'), name: const Value('普益投'), type: const Value('consumer'), icon: const Value('account_balance'), color: const Value('#607D8B')),
      
      // ===== 银行信用卡分期 =====
      LocalCreditInstitutionsCompanion(institutionId: const Value('icbc_card'), name: const Value('工行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#C41230')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('abc_card'), name: const Value('农行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#138D26')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('boc_card'), name: const Value('中行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#D4A017')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('ccb_card'), name: const Value('建行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#003087')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('comm_card'), name: const Value('交行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#003F8A')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('cmb_card'), name: const Value('招行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#E31837')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('citic_card'), name: const Value('中信信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#C41230')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('ceb_card'), name: const Value('光大信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#FF6600')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('cmbc_card'), name: const Value('民生信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#003A70')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('pab_card'), name: const Value('平安信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#E85D04')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('spdb_card'), name: const Value('浦发信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#00347A')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('cib_card'), name: const Value('兴业信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#003087')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('hxb_card'), name: const Value('华夏信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#E85D04')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('cgb_card'), name: const Value('广发信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#E60012')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('psbc_card'), name: const Value('邮储信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#00865A')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('shanghai_card'), name: const Value('上海银行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#0066B3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('beijing_card'), name: const Value('北京银行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#1E6BB8')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('nanjing_card'), name: const Value('南京银行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#0066CC')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('ningbo_card'), name: const Value('宁波银行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#0066CC')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('hangzhou_card'), name: const Value('杭州银行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#0066CC')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('guangzhou_card'), name: const Value('广州银行信用卡'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#0066B3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('shenzhen_card'), name: const Value('深圳前海银行'), type: const Value('credit'), icon: const Value('credit_card'), color: const Value('#0066B3')),
      
      // ===== 银行个人贷款 =====
      LocalCreditInstitutionsCompanion(institutionId: const Value('icbc_loan'), name: const Value('工行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#C41230')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('abc_loan'), name: const Value('农行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#138D26')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('boc_loan'), name: const Value('中行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#D4A017')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('ccb_loan'), name: const Value('建行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#003087')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('comm_loan'), name: const Value('交行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#003F8A')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('cmb_loan'), name: const Value('招行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#E31837')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('citic_loan'), name: const Value('中信个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#C41230')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('ceb_loan'), name: const Value('光大个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#FF6600')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('pab_loan'), name: const Value('平安个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#E85D04')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('psbc_loan'), name: const Value('邮储个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#00865A')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('shanghai_loan'), name: const Value('上海银行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#0066B3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('beijing_loan'), name: const Value('北京银行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#1E6BB8')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('hunan_loan'), name: const Value('湖南银行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#0066B3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('changsha_loan'), name: const Value('长沙银行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#E60012')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('jiangsu_loan'), name: const Value('江苏银行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#0066CC')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('nanjing_loan'), name: const Value('南京银行个人贷款'), type: const Value('loan'), icon: const Value('account_balance'), color: const Value('#0066CC')),
      
      // ===== 小额贷款公司 =====
      LocalCreditInstitutionsCompanion(institutionId: const Value('alipay_dai'), name: const Value('网商贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#1677FF')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('webank_dai'), name: const Value('微众贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#07C160')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('newbank_dai'), name: const Value('新网银行好人贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#1677FF')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('zb_dai'), name: const Value('众邦银行多帮贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#FF6600')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('yzz_dai'), name: const Value('裕民银行秒秒贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#1677FF')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('zgc_dai'), name: const Value('中关村银行个人贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#1677FF')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('hx_dai'), name: const Value('华西银行小额贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#0066B3')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('cs_dai'), name: const Value('长沙银行快乐秒贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#E60012')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('nj_dai'), name: const Value('南京银行诚易贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#0066CC')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('sh_dai'), name: const Value('上海银行信用贷'), type: const Value('microloan'), icon: const Value('payments'), color: const Value('#0066B3')),
      
      // ===== 典当/担保 =====
      LocalCreditInstitutionsCompanion(institutionId: const Value('pawn'), name: const Value('典当行'), type: const Value('pawn'), icon: const Value('payments'), color: const Value('#795548')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('guarantee'), name: const Value('担保公司'), type: const Value('guarantee'), icon: const Value('payments'), color: const Value('#795548')),
      LocalCreditInstitutionsCompanion(institutionId: const Value('pawnshop'), name: const Value('寄卖行'), type: const Value('pawn'), icon: const Value('payments'), color: const Value('#795548')),
      
      // ===== 其他 =====
      LocalCreditInstitutionsCompanion(institutionId: const Value('other_credit'), name: const Value('其他信贷'), type: const Value('other'), icon: const Value('account_balance'), color: const Value('#9E9E9E')),
    ];

    for (final inst in defaultInstitutions) {
      await into(localCreditInstitutions).insert(inst);
    }
  }

  /// 安全添加列（如果列已存在则不添加）
  Future<void> _addColumnIfNotExists(String table, String column, String type) async {
    // SQLite 不支持 IF NOT EXISTS 语法，需要先查询列是否存在
    final result = await customSelect(
      "PRAGMA table_info($table)",
    ).get();
    
    final columns = result.map((row) => row.read<String>('name').toLowerCase()).toList();
    if (!columns.contains(column.toLowerCase())) {
      await customStatement('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  Future<List<OfflineSyncQueueData>> getPendingSyncItems() {
    return (select(offlineSyncQueue)
          ..where((t) => t.status.equals(0) | t.status.equals(3))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<int> addSyncQueue(OfflineSyncQueueCompanion item) {
    return into(offlineSyncQueue).insert(item);
  }

  Future<void> updateSyncStatus(int id, int status, {DateTime? syncedAt}) {
    return (update(offlineSyncQueue)..where((t) => t.id.equals(id)))
        .write(OfflineSyncQueueCompanion(
      status: Value(status),
      syncedAt: Value(syncedAt),
    ));
  }

  Stream<List<LocalBillsData>> watchAllBills() {
    return (select(localBills)..orderBy([(t) => OrderingTerm.desc(t.billTime)]))
        .watch();
  }

  /// 获取所有账单（Future版本，用于统计计算）
  Future<List<LocalBillsData>> getAllBills() {
    return (select(localBills)..orderBy([(t) => OrderingTerm.desc(t.billTime)])).get();
  }

  /// 分页查询账单（按时间倒序）。首页列表懒加载使用。
  Future<List<LocalBillsData>> getBillsPage({int limit = 50, int offset = 0}) {
    return (select(localBills)
          ..orderBy([(t) => OrderingTerm.desc(t.billTime)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// 账单总条数（首页"已加载 X/Y" 用）
  Stream<int> watchBillsTotalCount() {
    final countExp = localBills.id.count();
    final query = selectOnly(localBills)..addColumns([countExp]);
    return query.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  /// 待同步数量（syncStatus=0）
  Stream<int> watchPendingSyncCount() {
    final countExp = localBills.id.count();
    final query = selectOnly(localBills)
      ..addColumns([countExp])
      ..where(localBills.syncStatus.equals(0));
    return query.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  /// 待确认数量（confirmStatus=0）
  Stream<int> watchUnconfirmedCount() {
    final countExp = localBills.id.count();
    final query = selectOnly(localBills)
      ..addColumns([countExp])
      ..where(localBills.confirmStatus.equals(0));
    return query.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  /// 首页汇总：今日支出 / 本月支出 / 本月收入
  /// 通过一个 trigger stream 监听 localBills 表变化，变化时重新聚合。
  /// 返回值统一为 Decimal 精确金额，避免 double 二进制浮点误差。
  Stream<Map<String, Decimal>> watchBillsSummary() {
    // trigger：监听 localBills 任意变化
    final trigger = selectOnly(localBills)..addColumns([localBills.id.count()]);
    return trigger.watchSingle().asyncMap((_) => getBillsSummary());
  }

  /// SQL 的 SUM 先以 REAL 取出，再经 decimalOf 逐笔还原为 Decimal。
  /// REAL 列存的是 2 位小数金额，SQL 加法有极小的二进制误差，
  /// 这里用 round2 收敛到分，保证汇总与 Dart 层逐笔累加一致。
  Future<Decimal> _sumAmount({required String type, required DateTime after}) async {
    final sumExp = localBills.amount.sum();
    final query = selectOnly(localBills)
      ..addColumns([sumExp])
      ..where(localBills.type.equals(type) & localBills.billTime.isBiggerOrEqualValue(after));
    final row = await query.getSingle();
    final raw = row.read(sumExp);
    return raw == null ? Decimal.zero : round2(decimalOf(raw));
  }

  /// Future 版本：一次拿当前汇总（供主动 refresh）
  Future<Map<String, Decimal>> getBillsSummary() async {
    final now = DateTime.now();
    final today0 = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);
    final todayExp = await _sumAmount(type: 'expense', after: today0);
    final monthExp = await _sumAmount(type: 'expense', after: monthStart);
    final monthInc = await _sumAmount(type: 'income', after: monthStart);
    return {
      'todayExpense': todayExp,
      'monthExpense': monthExp,
      'monthIncome': monthInc,
    };
  }

  Stream<List<LocalBillsData>> watchBillsByMonth(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    return (select(localBills)
          ..where((t) => t.billTime.isBetweenValues(startDate, endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.billTime)]))
        .watch();
  }

  Future<int> insertBill(LocalBillsCompanion bill) {
    return into(localBills).insert(bill);
  }

  /// 按 sourceHash 查是否已入账（自动记账防重复）
  Future<LocalBillsData?> findBillBySourceHash(String sourceHash) {
    return (select(localBills)
          ..where((t) => t.sourceHash.equals(sourceHash))
          ..limit(1))
        .getSingleOrNull();
  }

  /// 近期同渠道、同 App 分类名、同金额（备注偶发变化时的兜底去重）
  Future<LocalBillsData?> findRecentSimilarAutoBill({
    required String recordSource,
    required String appSourceName,
    required double amount,
    required Duration within,
  }) {
    final since = DateTime.now().subtract(within);
    return (select(localBills)
          ..where(
            (t) =>
                t.source.equals(recordSource) &
                t.categoryName.equals(appSourceName) &
                t.amount.equals(amount) &
                t.billTime.isBiggerOrEqualValue(since),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.billTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> updateBill(String billId, LocalBillsCompanion bill) {
    return (update(localBills)..where((t) => t.billId.equals(billId)))
        .write(bill);
  }

  Future<void> deleteBill(String billId) {
    return (delete(localBills)..where((t) => t.billId.equals(billId))).go();
  }

  Stream<List<LocalLiabilitiesData>> watchAllLiabilities() {
    return (select(localLiabilities)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<LocalLiabilitiesData>> getAllLiabilities() {
    return (select(localLiabilities)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<LocalLiabilitiesData?> getLiabilityById(String liabilityId) {
    return (select(localLiabilities)
          ..where((t) => t.liabilityId.equals(liabilityId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> insertLiability(LocalLiabilitiesCompanion liability) {
    return into(localLiabilities).insert(liability);
  }

  Future<void> updateLiability(String liabilityId, LocalLiabilitiesCompanion data) {
    return (update(localLiabilities)..where((t) => t.liabilityId.equals(liabilityId)))
        .write(data);
  }

  Future<void> deleteLiability(String liabilityId) {
    return (delete(localLiabilities)..where((t) => t.liabilityId.equals(liabilityId))).go();
  }

  Future<void> deleteRepaysByLiability(String liabilityId) {
    return (delete(localLiabilityRepays)..where((t) => t.liabilityId.equals(liabilityId))).go();
  }

  Stream<List<LocalLiabilityRepaysData>> watchRepaysByLiability(String liabilityId) {
    return (select(localLiabilityRepays)
          ..where((t) => t.liabilityId.equals(liabilityId))
          ..orderBy([(t) => OrderingTerm.desc(t.repayTime)]))
        .watch();
  }

  /// 全量还款流水 watch（用于负债页"本月/下月待还"重算）
  Stream<List<LocalLiabilityRepaysData>> watchAllRepays() {
    return (select(localLiabilityRepays)
          ..orderBy([(t) => OrderingTerm.desc(t.repayTime)]))
        .watch();
  }

  Future<int> insertRepay(LocalLiabilityRepaysCompanion repay) {
    return into(localLiabilityRepays).insert(repay);
  }

  Stream<List<LocalAccountsData>> watchAllAccounts() {
    return (select(localAccounts)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  }

  Future<int> insertAccount(LocalAccountsCompanion account) {
    return into(localAccounts).insert(account);
  }

  Future<LocalUserConfigData?> getUserConfig() async {
    final results = await select(localUserConfig).get();
    if (results.isEmpty) return null;
    if (results.length == 1) return results.first;

    // 历史 bug：无 id 的 insertOnConflictUpdate 会不断插新行。
    // 合并开关状态后只保留最新一行，避免每次进 App 开关又变回关闭。
    results.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final keep = results.first;
    final anyNotification =
        results.any((r) => r.notificationAutoRecordEnabled);
    final anyAccessibility =
        results.any((r) => r.accessibilityAutoRecordEnabled);
    final anySms = results.any((r) => r.smsListenEnabled);
    final anyNotifListen = results.any((r) => r.notificationListenEnabled);

    await (update(localUserConfig)..where((t) => t.id.equals(keep.id))).write(
      LocalUserConfigCompanion(
        notificationAutoRecordEnabled: Value(anyNotification),
        accessibilityAutoRecordEnabled: Value(anyAccessibility),
        smsListenEnabled: Value(anySms),
        notificationListenEnabled: Value(anyNotifListen),
        updatedAt: Value(DateTime.now()),
      ),
    );
    final duplicateIds =
        results.skip(1).map((r) => r.id).toList(growable: false);
    if (duplicateIds.isNotEmpty) {
      await (delete(localUserConfig)..where((t) => t.id.isIn(duplicateIds)))
          .go();
    }
    return (await (select(localUserConfig)
          ..where((t) => t.id.equals(keep.id)))
        .getSingleOrNull());
  }

  /// 更新用户配置：始终改已有行；没有配置时才插入。
  /// 注意：不可用无 id 的 insertOnConflictUpdate（自增主键不会冲突，会不断插新行）。
  Future<int> insertOrUpdateUserConfig(LocalUserConfigCompanion config) async {
    final existing = await getUserConfig();
    if (existing != null) {
      return (update(localUserConfig)..where((t) => t.id.equals(existing.id)))
          .write(config);
    }
    return into(localUserConfig).insert(config);
  }

  /// 咕咕鱼 AI 聊天历史（按时间升序返回）。
  /// - 不传 [beforeId]：取最新 [limit] 条
  /// - 传 [beforeId]：取 id 更小（更早）的 [limit] 条，用于下拉加载
  Future<List<LocalAiChatMessageData>> getAiChatMessages({
    int limit = 50,
    int? beforeId,
  }) async {
    final query = select(localAiChatMessages)
      ..orderBy([(t) => OrderingTerm.desc(t.id)])
      ..limit(limit);
    if (beforeId != null) {
      query.where((t) => t.id.isSmallerThanValue(beforeId));
    }
    final rows = await query.get();
    return rows.reversed.toList();
  }

  Future<int> insertAiChatMessage(LocalAiChatMessagesCompanion message) async {
    final id = await into(localAiChatMessages).insert(message);
    // 控制体积：超出则删掉更早的，只留最近 500 条
    final idCol = localAiChatMessages.id;
    final idsDesc = await (selectOnly(localAiChatMessages)
          ..addColumns([idCol])
          ..orderBy([OrderingTerm.desc(idCol)]))
        .map((row) => row.read(idCol)!)
        .get();
    if (idsDesc.length > 500) {
      final removeIds = idsDesc.sublist(500);
      await (delete(localAiChatMessages)..where((t) => t.id.isIn(removeIds)))
          .go();
    }
    return id;
  }

  Future<int> clearAiChatMessages() {
    return delete(localAiChatMessages).go();
  }

  /// 更新分类排序和使用次数
  Future<void> updateCategoryOrderAndUsage(String orderJson, String usageJson) async {
    final config = await getUserConfig();
    if (config != null) {
      await (update(localUserConfig)..where((t) => t.id.equals(config.id))).write(
        LocalUserConfigCompanion(
          categoryOrder: Value(orderJson),
          categoryUsage: Value(usageJson),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await into(localUserConfig).insert(
        LocalUserConfigCompanion.insert(
          categoryOrder: Value(orderJson),
          categoryUsage: Value(usageJson),
        ),
      );
    }
  }

  // ========== 分类管理 ==========

  Stream<List<LocalCategoriesData>> watchAllCategories() {
    return (select(localCategories)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Stream<List<LocalCategoriesData>> watchCategoriesByType(String type) {
    return (select(localCategories)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  /// 获取所有分类（Future版本）
  Future<List<LocalCategoriesData>> getAllCategories() {
    return (select(localCategories)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
  }

  /// 获取顶级大分类（parentId 为 null）
  Stream<List<LocalCategoriesData>> watchParentCategories({String? type}) {
    final query = select(localCategories)
      ..where((t) => t.parentId.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    if (type != null) {
      query.where((t) => t.type.equals(type));
    }
    return query.watch();
  }

  /// 获取顶级大分类（Future版本）
  Future<List<LocalCategoriesData>> getParentCategories({String? type}) async {
    final query = select(localCategories)
      ..where((t) => t.parentId.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    if (type != null) {
      query.where((t) => t.type.equals(type));
    }
    return query.get();
  }

  /// 获取某个大分类下的所有小分类
  Stream<List<LocalCategoriesData>> watchSubCategories(String parentId) {
    return (select(localCategories)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  /// 获取某个大分类下的所有小分类（Future版本）
  Future<List<LocalCategoriesData>> getSubCategories(String parentId) {
    return (select(localCategories)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// 根据分类ID获取分类信息
  Future<LocalCategoriesData?> getCategoryById(String categoryId) async {
    final results = await (select(localCategories)
          ..where((t) => t.categoryId.equals(categoryId)))
        .get();
    return results.isEmpty ? null : results.first;
  }

  /// 获取某类型的所有大分类及其子分类
  Future<Map<LocalCategoriesData, List<LocalCategoriesData>>> getCategoriesWithSubs({String? type}) async {
    final parents = await getParentCategories(type: type);
    final result = <LocalCategoriesData, List<LocalCategoriesData>>{};
    for (final parent in parents) {
      final subs = await getSubCategories(parent.categoryId);
      result[parent] = subs;
    }
    return result;
  }

  Future<int> insertCategory(LocalCategoriesCompanion category) {
    return into(localCategories).insert(category);
  }

  Future<void> updateCategory(String categoryId, LocalCategoriesCompanion data) {
    return (update(localCategories)..where((t) => t.categoryId.equals(categoryId)))
        .write(data);
  }

  Future<void> deleteCategory(String categoryId) {
    return (delete(localCategories)..where((t) => t.categoryId.equals(categoryId))).go();
  }

  /// 删除分类及其所有子分类
  Future<void> deleteCategoryWithSubs(String categoryId) async {
    // 先删除所有子分类
    await (delete(localCategories)..where((t) => t.parentId.equals(categoryId))).go();
    // 再删除父分类
    await deleteCategory(categoryId);
  }

  // ========== 银行机构管理 ==========

  Stream<List<LocalBanksData>> watchAllBanks() {
    return (select(localBanks)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  }

  Future<List<LocalBanksData>> getAllBanks() {
    return (select(localBanks)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
  }

  Future<int> insertBank(LocalBanksCompanion bank) {
    return into(localBanks).insert(bank);
  }

  Future<void> updateBank(String bankId, LocalBanksCompanion data) {
    return (update(localBanks)..where((t) => t.bankId.equals(bankId)))
        .write(data);
  }

  Future<void> deleteBank(String bankId) {
    return (delete(localBanks)..where((t) => t.bankId.equals(bankId))).go();
  }

  /// 按关键字搜索银行（模糊匹配 name / code / bankId）
  Future<List<LocalBanksData>> searchBanks(String keyword) {
    final like = '%${keyword.trim()}%';
    return (select(localBanks)
          ..where((t) => t.name.like(like) | t.code.like(like) | t.bankId.like(like))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  // ========== 信贷机构管理 ==========

  Stream<List<LocalCreditInstitutionsData>> watchAllCreditInstitutions() {
    return (select(localCreditInstitutions)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();
  }

  Future<List<LocalCreditInstitutionsData>> getAllCreditInstitutions() {
    return (select(localCreditInstitutions)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
  }

  Future<int> insertCreditInstitution(LocalCreditInstitutionsCompanion institution) {
    return into(localCreditInstitutions).insert(institution);
  }

  Future<void> updateCreditInstitution(String institutionId, LocalCreditInstitutionsCompanion data) {
    return (update(localCreditInstitutions)..where((t) => t.institutionId.equals(institutionId)))
        .write(data);
  }

  Future<void> deleteCreditInstitution(String institutionId) {
    return (delete(localCreditInstitutions)..where((t) => t.institutionId.equals(institutionId))).go();
  }

  /// 搜索信贷机构（按名称模糊搜索）
  Future<List<LocalCreditInstitutionsData>> searchCreditInstitutions(String keyword) {
    return (select(localCreditInstitutions)
          ..where((t) => t.name.like('%$keyword%'))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// 按类型筛选信贷机构
  Future<List<LocalCreditInstitutionsData>> getCreditInstitutionsByType(String type) {
    return (select(localCreditInstitutions)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// 按多个类型筛选信贷机构
  Future<List<LocalCreditInstitutionsData>> getCreditInstitutionsByTypes(List<String> types) {
    return (select(localCreditInstitutions)
          ..where((t) => t.type.isIn(types))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// 在指定类型范围内搜索信贷机构（按名称模糊搜索）
  Future<List<LocalCreditInstitutionsData>> searchCreditInstitutionsByTypes(
      String keyword, List<String> types) {
    return (select(localCreditInstitutions)
          ..where((t) => t.name.like('%$keyword%') & t.type.isIn(types))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// 获取消费分期类信贷产品（credit类型，用于消费分期和月付）
  Future<List<LocalCreditInstitutionsData>> getCreditProducts() {
    return (select(localCreditInstitutions)
          ..where((t) => t.type.isIn(['credit', 'microloan', 'consumer']))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aijizhang.db'));
    return NativeDatabase.createInBackground(file);
  });
}