import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../pages/liability/liability_theme.dart';
import '../providers/bill_provider.dart';
import '../providers/liability_provider.dart';
import '../utils/money.dart';
import 'deepseek_config.dart';

/// AI 解析出的单笔账单
class AiBillDraft {
  final String type; // expense / income
  final Decimal amount;
  final String parentCategory;
  final String? subCategory;
  final String? remark;

  AiBillDraft({
    required this.type,
    required this.amount,
    required this.parentCategory,
    this.subCategory,
    this.remark,
  });
}

/// AI 解析出的一笔负债（逻辑对齐手动新增负债）
class AiLiabilityDraft {
  final String type; // credit_card / mortgage / car_loan / installment / personal / other
  final String name;
  final Decimal amount;
  final String? institution;
  final int? repayDay; // 每月还款日 1-31
  final DateTime? dueDate;
  final String? remark;

  AiLiabilityDraft({
    required this.type,
    required this.name,
    required this.amount,
    this.institution,
    this.repayDay,
    this.dueDate,
    this.remark,
  });
}

/// AI 解析出的一笔还债
class AiRepayDraft {
  final String? liabilityId;
  final String? liabilityName;
  final Decimal? amount;
  final bool payAll;
  final String? remark;

  AiRepayDraft({
    this.liabilityId,
    this.liabilityName,
    this.amount,
    this.payAll = false,
    this.remark,
  });
}

/// AI 一轮回复结果
class AiChatResult {
  final String reply;
  final String? stickerId;
  final List<AiBillDraft> bills;
  final List<AiLiabilityDraft> liabilities;
  final List<AiRepayDraft> repays;
  final List<String> recordedSummaries;

  AiChatResult({
    required this.reply,
    this.stickerId,
    required this.bills,
    required this.liabilities,
    required this.repays,
    required this.recordedSummaries,
  });
}

/// 咕咕鱼 AI：DeepSeek 对话 + 解析记账 / 记负债
class GuguAiService {
  GuguAiService(this._db, this._billProvider, this._liabilityProvider);

  final AppDatabase _db;
  final BillProvider _billProvider;
  final LiabilityProvider _liabilityProvider;

  static const _liabilityTypes = <String>{
    'credit_card',
    'mortgage',
    'car_loan',
    'installment',
    'personal',
    'other',
  };
  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  final _uuid = const Uuid();

  Future<({bool enabled, String apiKey, String personalityId})> loadConfig() async {
    final config = await _db.getUserConfig();
    return (
      enabled: config?.aiEnabled ?? false,
      apiKey: (config?.aiApiKey ?? '').trim(),
      personalityId: config?.aiPersonality ?? AiPersonality.defaultId,
    );
  }

  /// 把用户一句话发给 AI，记账并返回调侃回复
  Future<AiChatResult> chatAndBook(String userText) async {
    final cfg = await loadConfig();
    if (!cfg.enabled) {
      throw Exception('请先在设置里启用 AI');
    }
    if (cfg.apiKey.isEmpty) {
      throw Exception('请先在 AI 设置里填写 DeepSeek API Key');
    }

    var categories = await _db.getAllCategories();
    final openLiabilities = (await _db.getAllLiabilities())
        .where((l) => l.status == 0)
        .toList();
    final catalog = _buildCategoryCatalog(categories);
    final liabilityCatalog = _buildLiabilityCatalog(openLiabilities);
    final personality = AiPersonality.byId(cfg.personalityId);
    final systemPrompt = _buildSystemPrompt(
      catalog,
      personality,
      liabilityCatalog: liabilityCatalog,
    );

    // 欠债 / 还债 / 记账一律把用户原话交给 DeepSeek，由 AI 返回结构化 JSON
    final content = await _callDeepSeek(
      apiKey: cfg.apiKey,
      systemPrompt: systemPrompt,
      userText: _wrapUserUtterance(userText.trim()),
    );
    debugPrint(
      'AI 原始返回(前500字): ${content.length > 500 ? content.substring(0, 500) : content}',
    );

    final parsed = _parseAiJson(content);
    final drafts = parsed.bills;
    final liabilityDrafts = parsed.liabilities;
    final repayDrafts = parsed.repays;
    debugPrint(
      'AI 解析结果 bills=${drafts.length} liabilities=${liabilityDrafts.length} repays=${repayDrafts.length}',
    );
    final summaries = <String>[];
    var reply = parsed.reply;

    for (final draft in drafts) {
      if (draft.amount <= Decimal.zero) continue;
      final resolved = await _resolveOrCreateCategory(
        type: draft.type,
        parentName: draft.parentCategory,
        subName: draft.subCategory,
        all: categories,
      );
      categories = await _db.getAllCategories();

      final ok = await _billProvider.addBill(
        type: draft.type,
        amount: draft.amount,
        accountId: 'cash',
        categoryId: resolved.categoryId,
        categoryName: resolved.categoryName,
        remark: draft.remark,
        source: 'ai',
      );
      if (ok) {
        final sign = draft.type == 'income' ? '+' : '-';
        final remarkPart =
            (draft.remark == null || draft.remark!.isEmpty) ? '' : '（${draft.remark}）';
        summaries.add(
          '$sign¥${formatMoney(draft.amount)} ${resolved.categoryName}$remarkPart',
        );
      }
    }

    for (final draft in liabilityDrafts) {
      if (draft.amount <= Decimal.zero) continue;
      final typeLabel = getTypeConfig(draft.type).label;
      final repayDate = draft.repayDay == null
          ? null
          : _firstPaymentFromRepayDay(draft.repayDay!);
      final ok = await _liabilityProvider.addLiability(
        name: draft.name,
        type: draft.type,
        accountId: 'cash',
        totalAmount: draft.amount,
        dueDate: draft.dueDate ??
            DateTime.now().add(const Duration(days: 30)),
        remark: draft.remark,
        institution: draft.institution,
        firstPaymentDate: repayDate,
        repayDate: repayDate,
      );
      if (ok) {
        final inst = (draft.institution == null || draft.institution!.isEmpty)
            ? ''
            : ' · ${draft.institution}';
        final day = draft.repayDay == null ? '' : ' · 每月${draft.repayDay}号还';
        summaries.add(
          '负债 ¥${formatMoney(draft.amount)} $typeLabel$inst · ${draft.name}$day',
        );
      }
    }

    // 还债：优先匹配未结清负债，写入还款流水 + 负债还款账单
    var latestOpen = (await _db.getAllLiabilities())
        .where((l) => l.status == 0)
        .toList();
    for (final draft in repayDrafts) {
      final matched = _matchOpenLiability(draft, latestOpen);
      if (matched == null) {
        summaries.add(
          '还债失败：找不到「${draft.liabilityName ?? draft.liabilityId ?? '未指定'}」这笔未结清负债',
        );
        continue;
      }
      final remaining =
          decimalOf(matched.totalAmount) - decimalOf(matched.repaidAmount);
      if (remaining <= Decimal.zero) {
        summaries.add('还债跳过：${matched.name} 已还清');
        continue;
      }

      Decimal payAmount;
      if (draft.payAll) {
        payAmount = remaining;
      } else if (draft.amount != null && draft.amount! > Decimal.zero) {
        payAmount = draft.amount!;
      } else {
        summaries.add('还债失败：${matched.name} 没说还多少');
        continue;
      }
      if (payAmount > remaining) {
        payAmount = remaining;
      }

      try {
        await _liabilityProvider.addRepay(
          liabilityId: matched.liabilityId,
          amount: payAmount,
          accountId: 'cash',
          remark: draft.remark ?? 'AI还债',
        );
        final cleared = payAmount >= remaining;
        summaries.add(
          '还债 -¥${formatMoney(payAmount)} ${matched.name}${cleared ? '（已结清）' : ''}',
        );
        latestOpen = (await _db.getAllLiabilities())
            .where((l) => l.status == 0)
            .toList();
      } catch (e) {
        final msg = e.toString().replaceFirst('Exception: ', '').replaceFirst('ArgumentError: ', '');
        summaries.add('还债失败：$msg');
        if (reply.isEmpty) reply = msg;
      }
    }

    return AiChatResult(
      reply: reply.isEmpty ? '收到啦，我先帮你记着～🐟' : reply,
      stickerId: parsed.stickerId ?? 'fish_hi',
      bills: drafts,
      liabilities: liabilityDrafts,
      repays: repayDrafts,
      recordedSummaries: summaries,
    );
  }

  String _buildCategoryCatalog(List<LocalCategoriesData> all) {
    final parents = all.where((c) => c.parentId == null).toList();
    final buf = StringBuffer();
    for (final p in parents) {
      final subs = all.where((c) => c.parentId == p.categoryId).toList();
      buf.writeln('- 【${p.type}】大类「${p.name}」');
      if (subs.isEmpty) {
        buf.writeln('  （暂无小类）');
      } else {
        for (final s in subs) {
          buf.writeln('  - 小类「${s.name}」');
        }
      }
    }
    return buf.toString();
  }

  String _buildLiabilityCatalog(List<LocalLiabilitiesData> open) {
    if (open.isEmpty) return '（当前没有未结清负债）';
    final buf = StringBuffer();
    for (final l in open) {
      final remaining = decimalOf(l.totalAmount) - decimalOf(l.repaidAmount);
      final typeLabel = getTypeConfig(l.type).label;
      final inst = (l.institution == null || l.institution!.isEmpty)
          ? ''
          : ' 机构=${l.institution}';
      buf.writeln(
        '- id=${l.liabilityId} 名称「${l.name}」类型=$typeLabel$inst 待还=¥${formatMoney(remaining)}',
      );
    }
    return buf.toString();
  }

  String _buildSystemPrompt(
    String catalog,
    AiPersonality personality, {
    String liabilityCatalog = '',
  }) {
    return '''
你是「咕咕鱼」记账助手。reply 必须像该性格本人在说话，禁止中性客服腔、禁止五种性格混搭。
【当前性格｜${personality.label}】请完整遵守下列全部细则（人设/节奏/用词/场景/正反例）：
${personality.prompt}

表达与输出要求：
1. reply 严格贴合性格；优先模仿【正例】，远离【反例】。
2. 贵贱必须结合「物品常识 + 价格」判断，禁止固定金额阈值（如 >300 就惊讶）；午饭贵可以惊讶，手机两千通常别当离谱。
3. 禁止固定收尾口头禅，句式每次自然变化，避免人机复读。
4. emoji 与 sticker 都按当场情绪/物品现选，禁止每条复用同一套；reply 里 emoji 可有可无。sticker 每次仍要给一个，且只能从：${AiSticker.promptList()}
5. 记账/记负债/还债准确性优先：金额、分类、匹配错了比性格不到位更严重。
6. 不要复述性格设定，只输出 JSON。

【重要】用户每一句自然语言都会原样通过接口发给你；你必须自行理解并只返回 JSON 数据。
本地不会用正则拆「欠债/还债」，结构化字段只能来自你的返回。

意图区分：
- 普通花销/到账 → bills
- 新欠款、新借款、新信用卡账单、新房贷车贷、新分期 → liabilities（新增负债）
- 偿还已有欠款（还张三、还信用卡、还贷、还清） → repays（还债；禁止新建 liabilities，禁止记成 bills 普通支出）
三者可同时出现。

【正例】
- 用户：「欠张三 2000」→ liabilities=[{type:personal,name:张三借款,amount:2000}]，bills=[]，repays=[]
- 用户：「招行信用卡欠了 3500，每月 8 号还」→ liabilities=[{type:credit_card,name:招行信用卡,amount:3500,institution:招商银行,repay_day:8}]
- 用户：「还张三 500」→ repays=[{liability_name:张三,amount:500}]（从下面负债目录匹配），liabilities=[]
- 用户：「信用卡还清了」→ repays=[{liability_name:信用卡,pay_all:true}]
- 用户：「午饭 28」→ bills=[{type:expense,amount:28,...}]，liabilities=[]，repays=[]

现有分类目录（优先复用，名称必须尽量一致；没有合适的才新建）：
$catalog

当前未结清负债目录（还债时优先用这里的 id / 名称匹配）：
$liabilityCatalog

负债类型只能是：credit_card(信用卡)、mortgage(房贷)、car_loan(车贷)、installment(消费分期)、personal(私人借款)、other(月付信贷)。

你必须只输出一个 JSON 对象（不要 Markdown 代码块，不要其它解释），格式严格如下：
{
  "reply": "给用户看的一句话反馈，语气符合性格，并含 emoji",
  "sticker": "表情包id，必须来自上面列表",
  "bills": [
    {
      "type": "expense 或 income",
      "amount": 数字,
      "parent_category": "大分类名称",
      "sub_category": "小分类名称，可空字符串",
      "remark": "备注，可空"
    }
  ],
  "liabilities": [
    {
      "type": "credit_card/mortgage/car_loan/installment/personal/other 之一",
      "name": "负债名称，如招行信用卡/张三借款",
      "amount": 数字,
      "institution": "银行或机构名，可空",
      "repay_day": 每月还款日1到31，可空数字,
      "due_date": "YYYY-MM-DD，可空",
      "remark": "备注，可空"
    }
  ],
  "repays": [
    {
      "liability_id": "优先填未结清负债目录里的 id，可空",
      "liability_name": "要还的那笔名称/关键词，如张三、招行信用卡",
      "amount": 数字，还清时可空,
      "pay_all": false,
      "remark": "备注，可空"
    }
  ]
}

规则：
1. 若无法识别意图，bills / liabilities / repays 都可为 []，reply 说明原因并引导，仍要 sticker。
2. 可返回多笔账单、负债、还款。
3. bills.type 只能是 expense 或 income。
4. parent_category / sub_category 优先用目录已有名称；确需新建时用简洁中文名。
5. amount 必须是正数（还清时可用 pay_all=true）。
6. liabilities 只用于「新欠」；repays 只用于「还已有债」。
7. 还债必须尽量填 liability_id；没有 id 就填 liability_name 与目录对齐。
8. 「还清/全部还了」→ pay_all=true；「还了 500」→ amount=500。
9. 目录里没有匹配负债又要还债时：repays 仍可返回，但 reply 说明找不到，引导用户先记负债或说清楚名称。
10. 禁止自行编造未在用户原话中出现的金额。
''';
  }

  /// 把用户自然语言包装后传给接口，明确要求 AI 返回结构化数据
  String _wrapUserUtterance(String raw) {
    return '''
【用户自然语言原话】
$raw

请只根据上面原话判断意图，并返回 JSON（必须包含 reply、sticker、bills、liabilities、repays 字段；没有的用空数组 []）。
- 新欠债/借款/信用卡欠款等 → 填 liabilities
- 还债/还款/还清 → 填 repays（对照系统提示里的未结清负债目录）
- 普通消费/收入 → 填 bills
不要解释，不要 Markdown，只输出一个 JSON 对象。
''';
  }

  Future<String> _callDeepSeek({
    required String apiKey,
    required String systemPrompt,
    required String userText,
  }) async {
    final url =
        '${DeepSeekDefaults.baseUrl}${DeepSeekDefaults.chatCompletionsPath}';
    try {
      debugPrint('DeepSeek 请求用户原话包装后长度=${userText.length}');
      final resp = await _dio.post(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
        data: {
          'model': DeepSeekDefaults.model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userText},
          ],
          'stream': false,
          // 结构化记账/负债/还债，略降温度提高 JSON 稳定
          'temperature': 0.4,
        },
      );
      final data = resp.data;
      if (data is! Map) {
        throw Exception('AI 返回格式异常');
      }
      final choices = data['choices'];
      if (choices is! List || choices.isEmpty) {
        throw Exception('AI 无有效回复');
      }
      final message = choices.first['message'];
      final content = message is Map ? message['content']?.toString() : null;
      if (content == null || content.trim().isEmpty) {
        throw Exception('AI 回复为空');
      }
      return content.trim();
    } on DioException catch (e) {
      final body = e.response?.data;
      debugPrint('DeepSeek 请求失败: ${e.message} body=$body');
      final detail = body is Map && body['error'] != null
          ? body['error'].toString()
          : (e.message ?? '$e');
      throw Exception('AI 请求失败：$detail');
    }
  }

  ({
    String reply,
    String? stickerId,
    List<AiBillDraft> bills,
    List<AiLiabilityDraft> liabilities,
    List<AiRepayDraft> repays,
  }) _parseAiJson(String raw) {
    var text = raw.trim();
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```', multiLine: true);
    final m = fence.firstMatch(text);
    if (m != null) {
      text = m.group(1)!.trim();
    }
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) {
      return (
        reply: text.isEmpty ? '我没太听懂诶🤔 再说具体点？' : text,
        stickerId: 'think',
        bills: <AiBillDraft>[],
        liabilities: <AiLiabilityDraft>[],
        repays: <AiRepayDraft>[],
      );
    }
    text = text.substring(start, end + 1);

    late final dynamic decoded;
    try {
      decoded = jsonDecode(text);
    } catch (_) {
      return (
        reply: '解析失败了😅 换种说法试试？',
        stickerId: 'think',
        bills: <AiBillDraft>[],
        liabilities: <AiLiabilityDraft>[],
        repays: <AiRepayDraft>[],
      );
    }
    if (decoded is! Map) {
      return (
        reply: '解析失败了😅 换种说法试试？',
        stickerId: 'think',
        bills: <AiBillDraft>[],
        liabilities: <AiLiabilityDraft>[],
        repays: <AiRepayDraft>[],
      );
    }
    final reply = decoded['reply']?.toString() ?? '';
    final stickerRaw =
        (decoded['sticker'] ?? decoded['sticker_id'] ?? '').toString().trim();
    final stickerId = AiSticker.byId(stickerRaw)?.id ??
        _guessSticker(
          reply,
          decoded['bills'],
          decoded['liabilities'],
          decoded['repays'],
        );

    final billsRaw = decoded['bills'];
    final bills = <AiBillDraft>[];
    if (billsRaw is List) {
      for (final item in billsRaw) {
        if (item is! Map) continue;
        final typeRaw = item['type']?.toString().toLowerCase() ?? 'expense';
        final type = typeRaw.contains('income') ? 'income' : 'expense';
        final amount = asDecimal(item['amount']);
        final parent = (item['parent_category'] ?? item['parentCategory'] ?? '')
            .toString()
            .trim();
        final sub = (item['sub_category'] ?? item['subCategory'] ?? '')
            .toString()
            .trim();
        final remark = (item['remark'] ?? '').toString().trim();
        if (parent.isEmpty || amount <= Decimal.zero) continue;
        bills.add(
          AiBillDraft(
            type: type,
            amount: amount,
            parentCategory: parent,
            subCategory: sub.isEmpty ? null : sub,
            remark: remark.isEmpty ? null : remark,
          ),
        );
      }
    }

    final liabilities = <AiLiabilityDraft>[];
    final liabRaw = decoded['liabilities'] ?? decoded['debts'];
    if (liabRaw is List) {
      for (final item in liabRaw) {
        if (item is! Map) continue;
        final draft = _parseLiabilityItem(item);
        if (draft != null) liabilities.add(draft);
      }
    }

    final repays = <AiRepayDraft>[];
    final repayRaw = decoded['repays'] ?? decoded['repayments'];
    if (repayRaw is List) {
      for (final item in repayRaw) {
        if (item is! Map) continue;
        final draft = _parseRepayItem(item);
        if (draft != null) repays.add(draft);
      }
    }

    return (
      reply: reply,
      stickerId: stickerId,
      bills: bills,
      liabilities: liabilities,
      repays: repays,
    );
  }

  AiRepayDraft? _parseRepayItem(Map item) {
    final id = (item['liability_id'] ?? item['liabilityId'] ?? '')
        .toString()
        .trim();
    final name = (item['liability_name'] ??
            item['liabilityName'] ??
            item['name'] ??
            '')
        .toString()
        .trim();
    final remark = (item['remark'] ?? '').toString().trim();
    final payAllRaw = item['pay_all'] ?? item['payAll'] ?? false;
    final payAll = payAllRaw == true ||
        payAllRaw.toString().toLowerCase() == 'true' ||
        payAllRaw.toString() == '1';

    Decimal? amount;
    if (item['amount'] != null) {
      final a = asDecimal(item['amount']);
      if (a > Decimal.zero) amount = a;
    }

    if (id.isEmpty && name.isEmpty) return null;
    if (!payAll && amount == null) {
      // 允许只有名称：后续再报「没说还多少」
    }

    return AiRepayDraft(
      liabilityId: id.isEmpty ? null : id,
      liabilityName: name.isEmpty ? null : name,
      amount: amount,
      payAll: payAll,
      remark: remark.isEmpty ? null : remark,
    );
  }

  LocalLiabilitiesData? _matchOpenLiability(
    AiRepayDraft draft,
    List<LocalLiabilitiesData> open,
  ) {
    if (open.isEmpty) return null;

    if (draft.liabilityId != null && draft.liabilityId!.isNotEmpty) {
      for (final l in open) {
        if (l.liabilityId == draft.liabilityId) return l;
      }
    }

    final key = (draft.liabilityName ?? '').trim();
    if (key.isEmpty) {
      // 没点名且只有一笔未结清，默认还这一笔
      return open.length == 1 ? open.first : null;
    }

    // 精确名称
    for (final l in open) {
      if (l.name == key) return l;
    }
    // 包含匹配（名称 / 机构 / 类型中文）
    LocalLiabilitiesData? best;
    var bestScore = 0;
    for (final l in open) {
      var score = 0;
      if (l.name.contains(key) || key.contains(l.name)) score += 3;
      final inst = l.institution ?? '';
      if (inst.isNotEmpty && (inst.contains(key) || key.contains(inst))) {
        score += 2;
      }
      final typeLabel = getTypeConfig(l.type).label;
      if (key.contains(typeLabel) || typeLabel.contains(key)) score += 1;
      if (score > bestScore) {
        bestScore = score;
        best = l;
      }
    }
    return bestScore > 0 ? best : null;
  }

  AiLiabilityDraft? _parseLiabilityItem(Map item) {
    final amount = asDecimal(item['amount'] ?? item['total_amount']);
    if (amount <= Decimal.zero) return null;

    final type = _normalizeLiabilityType(
      (item['type'] ?? item['liability_type'] ?? '').toString(),
      nameHint: (item['name'] ?? item['title'] ?? '').toString(),
      institutionHint:
          (item['institution'] ?? item['bank'] ?? '').toString(),
    );

    var name = (item['name'] ?? item['title'] ?? '').toString().trim();
    final institution =
        (item['institution'] ?? item['bank'] ?? '').toString().trim();
    if (name.isEmpty) {
      if (institution.isNotEmpty) {
        name = '$institution${getTypeConfig(type).label}';
      } else {
        name = getTypeConfig(type).label;
      }
    }

    int? repayDay;
    final dayRaw = item['repay_day'] ?? item['repayDay'] ?? item['day'];
    if (dayRaw != null) {
      final d = int.tryParse(dayRaw.toString().replaceAll(RegExp(r'[^0-9]'), ''));
      if (d != null && d >= 1 && d <= 31) repayDay = d;
    }

    DateTime? dueDate;
    final dueRaw = (item['due_date'] ?? item['dueDate'] ?? '').toString().trim();
    if (dueRaw.isNotEmpty) {
      dueDate = DateTime.tryParse(dueRaw);
    }

    final remark = (item['remark'] ?? '').toString().trim();

    return AiLiabilityDraft(
      type: type,
      name: name,
      amount: amount,
      institution: institution.isEmpty ? null : institution,
      repayDay: repayDay,
      dueDate: dueDate,
      remark: remark.isEmpty ? null : remark,
    );
  }

  String _normalizeLiabilityType(
    String raw, {
    required String nameHint,
    required String institutionHint,
  }) {
    final t = raw.trim().toLowerCase();
    if (_liabilityTypes.contains(t)) return t;

    final blob = '$raw $nameHint $institutionHint'.toLowerCase();
    if (blob.contains('credit') || blob.contains('信用卡') || blob.contains('卡债')) {
      return 'credit_card';
    }
    if (blob.contains('mortgage') || blob.contains('房贷') || blob.contains('房屋')) {
      return 'mortgage';
    }
    if (blob.contains('car') || blob.contains('车贷') || blob.contains('汽车')) {
      return 'car_loan';
    }
    if (blob.contains('installment') ||
        blob.contains('分期') ||
        blob.contains('花呗') ||
        blob.contains('白条')) {
      return 'installment';
    }
    if (blob.contains('personal') ||
        blob.contains('私人') ||
        blob.contains('借给') ||
        (blob.contains('向') && blob.contains('借')) ||
        (blob.contains('找') && blob.contains('借'))) {
      return 'personal';
    }
    if (blob.contains('other') ||
        blob.contains('月付') ||
        blob.contains('信贷') ||
        blob.contains('网贷')) {
      return 'other';
    }
    // 默认私人借款：口语「欠/借了」最常见
    return 'personal';
  }

  /// 与新增负债页一致：还款日已过则顺延下月
  DateTime _firstPaymentFromRepayDay(int repayDay) {
    final now = DateTime.now();
    var year = now.year;
    var month = now.month;
    if (now.day > repayDay) {
      month += 1;
      if (month > 12) {
        month = 1;
        year += 1;
      }
    }
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return DateTime(
      year,
      month,
      repayDay > daysInMonth ? daysInMonth : repayDay,
    );
  }

  String _guessSticker(
    String reply,
    dynamic billsRaw,
    dynamic liabilitiesRaw,
    dynamic repaysRaw,
  ) {
    final t = reply.toLowerCase();
    if (repaysRaw is List && repaysRaw.isNotEmpty) return 'clap';
    if (liabilitiesRaw is List && liabilitiesRaw.isNotEmpty) {
      return 'angry_cute';
    }
    if (billsRaw is List && billsRaw.isNotEmpty) {
      final first = billsRaw.first;
      if (first is Map) {
        final type = first['type']?.toString().toLowerCase() ?? '';
        if (type.contains('income')) return 'rich';
      }
      return 'ok';
    }
    if (t.contains('工资') || t.contains('入账') || t.contains('发财')) return 'rich';
    if (t.contains('还债') || t.contains('还清') || t.contains('还款')) return 'clap';
    if (t.contains('负债') || t.contains('欠') || t.contains('借款')) {
      return 'angry_cute';
    }
    if (t.contains('心疼') || t.contains('哭') || t.contains('败家')) {
      return 'cry_money';
    }
    if (t.contains('咖啡') || t.contains('奶茶')) return 'coffee';
    if (t.contains('吃') || t.contains('饭') || t.contains('餐')) return 'food';
    return 'fish_hi';
  }

  Future<({String categoryId, String categoryName})> _resolveOrCreateCategory({
    required String type,
    required String parentName,
    required String? subName,
    required List<LocalCategoriesData> all,
  }) async {
    LocalCategoriesData? parent;
    for (final c in all) {
      if (c.parentId == null && c.type == type && c.name == parentName) {
        parent = c;
        break;
      }
    }
    parent ??= () {
      for (final c in all) {
        if (c.parentId == null && c.name == parentName) return c;
      }
      return null;
    }();

    late final String parentId;
    late final String parentType;
    late final String parentIcon;
    late final String parentColor;
    late final String resolvedParentName;

    if (parent == null) {
      parentId = _uuid.v4();
      parentType = type;
      parentIcon = 'category';
      parentColor = type == 'income' ? '#43A047' : '#E53935';
      resolvedParentName = parentName;
      await _db.insertCategory(
        LocalCategoriesCompanion(
          categoryId: Value(parentId),
          name: Value(parentName),
          type: Value(type),
          icon: Value(parentIcon),
          color: Value(parentColor),
          parentId: const Value(null),
          sortOrder: const Value(50),
        ),
      );
    } else {
      parentId = parent.categoryId;
      parentType = parent.type;
      parentIcon = parent.icon;
      parentColor = parent.color;
      resolvedParentName = parent.name;
    }

    if (subName == null || subName.isEmpty) {
      return (categoryId: parentId, categoryName: resolvedParentName);
    }

    LocalCategoriesData? sub;
    for (final c in all) {
      if (c.parentId == parentId && c.name == subName) {
        sub = c;
        break;
      }
    }

    if (sub == null) {
      final subId = _uuid.v4();
      await _db.insertCategory(
        LocalCategoriesCompanion(
          categoryId: Value(subId),
          name: Value(subName),
          type: Value(parentType),
          icon: Value(parentIcon),
          color: Value(parentColor),
          parentId: Value(parentId),
          sortOrder: const Value(0),
        ),
      );
      return (categoryId: subId, categoryName: subName);
    }

    return (categoryId: sub.categoryId, categoryName: sub.name);
  }
}
