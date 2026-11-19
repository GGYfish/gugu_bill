import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import '../providers/app_provider.dart';
import '../providers/bill_provider.dart';
import '../providers/liability_provider.dart';
import '../services/deepseek_config.dart';
import '../services/gugu_ai_service.dart';
import '../ui_constants.dart';
import 'ai_settings_page.dart';

class _ChatMessage {
  final int? id;
  final bool isUser;
  final String text;
  final String? stickerId;
  final List<String>? billLines;
  final bool isError;
  final bool isSystem;
  final DateTime createdAt;

  _ChatMessage({
    this.id,
    required this.isUser,
    required this.text,
    this.stickerId,
    this.billLines,
    this.isError = false,
    this.isSystem = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory _ChatMessage.fromDb(LocalAiChatMessageData row) {
    List<String>? bills;
    try {
      final decoded = jsonDecode(row.billLinesJson);
      if (decoded is List) {
        bills = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      bills = null;
    }
    return _ChatMessage(
      id: row.id,
      isUser: row.isUser,
      text: row.content,
      stickerId: row.stickerId,
      billLines: bills == null || bills.isEmpty ? null : bills,
      isError: row.isError,
      isSystem: row.isSystem,
      createdAt: row.createdAt,
    );
  }

  _ChatMessage copyWith({
    int? id,
    bool? isUser,
    String? text,
    String? stickerId,
    Object? billLines = _copyKeep,
    bool? isError,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return _ChatMessage(
      id: id ?? this.id,
      isUser: isUser ?? this.isUser,
      text: text ?? this.text,
      stickerId: stickerId ?? this.stickerId,
      billLines: identical(billLines, _copyKeep)
          ? this.billLines
          : billLines as List<String>?,
      isError: isError ?? this.isError,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static const Object _copyKeep = Object();
}

/// 咕咕鱼 AI 聊天记账页
class GuguAiPage extends StatefulWidget {
  const GuguAiPage({super.key});

  @override
  State<GuguAiPage> createState() => _GuguAiPageState();
}

class _GuguAiPageState extends State<GuguAiPage> {
  static const int _pageSize = 50;

  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];

  AppDatabase? _db;
  GuguAiService? _service;
  bool _sending = false;
  bool _ready = false;
  bool _aiOk = false;
  bool _loadingHistory = true;
  bool _loadingOlder = false;
  bool _hasMore = true;
  bool _typewriterRunning = false;
  int _typewriterToken = 0;
  String _hint = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _typewriterToken++; // 取消进行中的打字机
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final app = context.read<AppProvider>();
    final bills = context.read<BillProvider>();
    final liabilities = context.read<LiabilityProvider>();
    _db = app.db;
    _service = GuguAiService(app.db, bills, liabilities);
    await _refreshConfig();
    await _loadHistory();
    if (!mounted) return;
    if (_messages.isEmpty) {
      await _appendMessage(
        _ChatMessage(
          isUser: false,
          text: _aiOk
              ? '嗨～我是咕咕鱼🐟 记账、记负债、还债都行。例如「午饭 28」「欠张三 2000」「还张三 500」「信用卡还清」。'
              : _hint,
          stickerId: _aiOk ? 'fish_hi' : null,
          isSystem: true,
        ),
        persist: true,
        typewriter: true,
      );
    } else {
      _scrollToEnd(immediate: true);
    }
  }

  int? get _oldestPersistedId {
    for (final m in _messages) {
      if (m.id != null) return m.id;
    }
    return null;
  }

  Future<void> _loadHistory() async {
    final db = _db;
    if (db == null) return;
    try {
      final rows = await db.getAiChatMessages(limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(rows.map(_ChatMessage.fromDb));
        _hasMore = rows.length >= _pageSize;
        _loadingHistory = false;
      });
    } catch (e) {
      debugPrint('加载 AI 聊天历史失败: $e');
      if (!mounted) return;
      setState(() {
        _loadingHistory = false;
        _hasMore = false;
      });
    }
  }

  /// 下拉：再往前加载 50 条更早的记录
  Future<void> _loadOlderMessages() async {
    if (_loadingOlder) return;
    final db = _db;
    if (db == null) return;

    if (!_hasMore) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('没有更多聊天记录了'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final beforeId = _oldestPersistedId;
    if (beforeId == null) {
      setState(() => _hasMore = false);
      return;
    }

    setState(() => _loadingOlder = true);
    try {
      final rows = await db.getAiChatMessages(
        limit: _pageSize,
        beforeId: beforeId,
      );
      if (!mounted) return;

      if (rows.isEmpty) {
        setState(() {
          _hasMore = false;
          _loadingOlder = false;
        });
        return;
      }

      final older = rows.map(_ChatMessage.fromDb).toList();
      final hadClients = _scrollController.hasClients;
      final oldMax =
          hadClients ? _scrollController.position.maxScrollExtent : 0.0;
      final oldPixels =
          hadClients ? _scrollController.position.pixels : 0.0;

      setState(() {
        _messages.insertAll(0, older);
        _hasMore = rows.length >= _pageSize;
        _loadingOlder = false;
      });

      // 保持当前可视位置，避免插入历史后整页跳到底
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        final newMax = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(oldPixels + (newMax - oldMax));
      });
    } catch (e) {
      debugPrint('加载更早聊天失败: $e');
      if (!mounted) return;
      setState(() => _loadingOlder = false);
    }
  }

  Future<void> _refreshConfig() async {
    final svc = _service;
    if (svc == null) return;
    final cfg = await svc.loadConfig();
    if (!mounted) return;
    setState(() {
      _ready = true;
      _aiOk = cfg.enabled && cfg.apiKey.isNotEmpty;
      if (!cfg.enabled) {
        _hint = '还没启用 AI，去设置里打开并填 DeepSeek Key 吧。';
      } else if (cfg.apiKey.isEmpty) {
        _hint = 'AI 已开启，但还没填 API Key，点右上角去配置。';
      } else {
        _hint = '';
      }
    });
  }

  Future<_ChatMessage> _persistMessage(_ChatMessage msg) async {
    final db = _db;
    if (db == null) return msg;
    try {
      final id = await db.insertAiChatMessage(
        LocalAiChatMessagesCompanion.insert(
          isUser: msg.isUser,
          content: msg.text,
          stickerId: Value(msg.stickerId),
          billLinesJson: Value(jsonEncode(msg.billLines ?? const <String>[])),
          isError: Value(msg.isError),
          isSystem: Value(msg.isSystem),
          createdAt: Value(msg.createdAt),
        ),
      );
      return msg.copyWith(id: id);
    } catch (e) {
      debugPrint('保存 AI 聊天失败: $e');
      return msg;
    }
  }

  /// 追加消息。助手回复默认打字机逐字输出；用户消息 / 历史回放保持瞬间出现。
  Future<_ChatMessage> _appendMessage(
    _ChatMessage msg, {
    bool persist = true,
    bool typewriter = false,
  }) async {
    if (!typewriter || msg.isUser || msg.text.isEmpty) {
      setState(() => _messages.add(msg));
      _scrollToEnd();
      if (!persist) return msg;
      final saved = await _persistMessage(msg);
      final idx = _messages.length - 1;
      if (mounted && idx >= 0) {
        setState(() => _messages[idx] = saved);
      }
      return saved;
    }

    return _appendWithTypewriter(msg, persist: persist);
  }

  int _typeDelayMs(int totalChars) {
    if (totalChars <= 36) return 30;
    if (totalChars <= 90) return 20;
    if (totalChars <= 160) return 14;
    return 10;
  }

  Future<_ChatMessage> _appendWithTypewriter(
    _ChatMessage full, {
    required bool persist,
  }) async {
    final token = ++_typewriterToken;
    _typewriterRunning = true;

    // 先出贴纸 + 空气泡，再逐字填字；记账摘要打完字再挂上
    final placeholder = full.copyWith(text: '', billLines: null);
    setState(() => _messages.add(placeholder));
    _scrollToEnd();

    final chars = full.text.characters.toList();
    final delay = _typeDelayMs(chars.length);
    final step = chars.length > 140 ? 2 : 1;
    final buf = StringBuffer();
    final idx = _messages.length - 1;

    for (var i = 0; i < chars.length; i += step) {
      if (!mounted || token != _typewriterToken) {
        _typewriterRunning = false;
        return full;
      }
      final end = (i + step < chars.length) ? i + step : chars.length;
      for (var j = i; j < end; j++) {
        buf.write(chars[j]);
      }
      setState(() {
        if (idx >= 0 && idx < _messages.length) {
          _messages[idx] = full.copyWith(
            text: buf.toString(),
            billLines: null,
          );
        }
      });
      if (i % (step * 4) == 0) _scrollToEnd();
      await Future<void>.delayed(Duration(milliseconds: delay));
    }

    if (!mounted || token != _typewriterToken) {
      _typewriterRunning = false;
      return full;
    }

    var finished = full;
    setState(() {
      if (idx >= 0 && idx < _messages.length) {
        _messages[idx] = finished;
      }
    });
    _scrollToEnd();

    if (persist) {
      finished = await _persistMessage(finished);
      if (mounted && token == _typewriterToken && idx < _messages.length) {
        setState(() => _messages[idx] = finished);
      }
    }

    _typewriterRunning = false;
    return finished;
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending || _typewriterRunning) return;
    final svc = _service;
    if (svc == null) return;

    _inputController.clear();

    if (!_aiOk) {
      await _appendMessage(_ChatMessage(isUser: true, text: text));
      await _appendMessage(
        _ChatMessage(isUser: false, text: _hint, isError: true),
        typewriter: true,
      );
      return;
    }

    setState(() => _sending = true);
    await _appendMessage(_ChatMessage(isUser: true, text: text));

    try {
      final result = await svc.chatAndBook(text);
      if (!mounted) return;
      // 先结束「思考中」，再打字输出
      setState(() => _sending = false);
      await _appendMessage(
        _ChatMessage(
          isUser: false,
          text: result.reply,
          stickerId: result.stickerId,
          billLines: result.recordedSummaries.isEmpty
              ? null
              : result.recordedSummaries,
        ),
        typewriter: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      await _appendMessage(
        _ChatMessage(
          isUser: false,
          text: e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        ),
        typewriter: true,
      );
    } finally {
      if (mounted && _sending) {
        setState(() => _sending = false);
      }
      _scrollToEnd();
    }
  }

  void _scrollToEnd({bool immediate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (immediate) {
        _scrollController.jumpTo(target);
      } else {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearHistory() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空聊天记录'),
        content: const Text('确定清空咕咕鱼的本地聊天历史吗？已记账单不会删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('清空', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final db = _db;
    if (db != null) {
      await db.clearAiChatMessages();
    }
    if (!mounted) return;
    setState(() {
      _messages.clear();
      _hasMore = false;
    });
    await _appendMessage(
      _ChatMessage(
        isUser: false,
        text: _aiOk
            ? '历史清掉啦～再说一笔账给我听🐟'
            : _hint,
        stickerId: _aiOk ? 'fish_hi' : null,
        isSystem: true,
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AiSettingsPage()),
    );
    await _refreshConfig();
    if (!mounted) return;
    if (_aiOk &&
        _messages.isNotEmpty &&
        !_messages.last.isUser &&
        _messages.last.isError) {
      await _appendMessage(
        _ChatMessage(
          isUser: false,
          text: '配置好了的话，再说一笔账试试～',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('咕咕鱼 AI'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: '清空聊天',
            onPressed: _loadingHistory ? null : _clearHistory,
            icon: Icon(Icons.delete_outline, color: AppColors.textSecondary),
          ),
          IconButton(
            tooltip: 'AI 设置',
            onPressed: _openSettings,
            icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_ready && !_aiOk)
            Material(
              color: AppColors.primary.withValues(alpha: 0.08),
              child: InkWell(
                onTap: _openSettings,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _hint.isEmpty ? '请先配置 DeepSeek API Key' : _hint,
                          style:
                              TextStyle(fontSize: 12, color: AppColors.primary),
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _loadOlderMessages,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      itemCount: _messages.length +
                          (_sending ? 1 : 0) +
                          (_hasMore || _loadingOlder ? 1 : 0),
                      itemBuilder: (context, index) {
                        final tipSlot = (_hasMore || _loadingOlder) ? 1 : 0;
                        if (tipSlot == 1 && index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Center(
                              child: Text(
                                _loadingOlder
                                    ? '加载中…'
                                    : '下拉加载更早的 50 条记录',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          );
                        }
                        final msgIndex = index - tipSlot;
                        if (_sending && msgIndex == _messages.length) {
                          return _typingBubble();
                        }
                        return _messageWithTime(msgIndex);
                      },
                    ),
                  ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  /// 微信风格：间隔超过 5 分钟（或首条）显示居中时间
  Widget _messageWithTime(int msgIndex) {
    final msg = _messages[msgIndex];
    final prev = msgIndex > 0 ? _messages[msgIndex - 1] : null;
    final showTime = prev == null ||
        msg.createdAt.difference(prev.createdAt).abs() >
            const Duration(minutes: 5);
    return Column(
      children: [
        if (showTime) _timeLabel(msg.createdAt),
        _bubble(msg),
      ],
    );
  }

  Widget _timeLabel(DateTime time) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.textTertiary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _formatChatTime(time),
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  String _formatChatTime(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(local.year, local.month, local.day);
    final diffDays = today.difference(thatDay).inDays;
    final clock = _wechatClock(local);

    if (diffDays == 0) return clock;
    if (diffDays == 1) return '昨天 $clock';
    if (diffDays > 1 && diffDays < 7) {
      const weeks = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
      return '${weeks[local.weekday - 1]} $clock';
    }
    if (local.year == now.year) {
      return '${local.month}月${local.day}日 $clock';
    }
    return '${local.year}年${local.month}月${local.day}日 $clock';
  }

  String _wechatClock(DateTime t) {
    final h = t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    final String period;
    if (h < 6) {
      period = '凌晨';
    } else if (h < 12) {
      period = '上午';
    } else if (h < 13) {
      period = '中午';
    } else if (h < 18) {
      period = '下午';
    } else {
      period = '晚上';
    }
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$period $displayH:$m';
  }

  Widget _typingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '咕咕鱼思考中…',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(_ChatMessage msg) {
    final align = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bg = msg.isUser
        ? AppColors.primary
        : (msg.isError
            ? AppColors.expense.withValues(alpha: 0.08)
            : AppColors.surface);
    final fg = msg.isUser
        ? Colors.white
        : (msg.isError ? AppColors.expense : AppColors.textPrimary);
    final sticker = msg.isUser ? null : AiSticker.byId(msg.stickerId);

    return Align(
      alignment: align,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 10,
          left: msg.isUser ? 48 : 0,
          right: msg.isUser ? 0 : 48,
        ),
        child: Column(
          crossAxisAlignment:
              msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (sticker != null)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child:
                    Text(sticker.emoji, style: const TextStyle(fontSize: 40)),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: msg.isUser
                    ? null
                    : Border.all(
                        color: msg.isError
                            ? AppColors.expense.withValues(alpha: 0.3)
                            : AppColors.divider,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(fontSize: 14, height: 1.4, color: fg),
                  ),
                  if (msg.billLines != null && msg.billLines!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? Colors.white.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.billLines!.any(
                              (e) =>
                                  e.startsWith('负债') ||
                                  e.startsWith('还债'),
                            )
                                ? '已记录'
                                : '已记账',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: msg.isUser
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...msg.billLines!.map(
                            (line) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                line,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: msg.isUser
                                      ? Colors.white.withValues(alpha: 0.95)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '例如：奶茶 18 / 欠张三 2000 / 还张三 500',
                  hintStyle:
                      TextStyle(fontSize: 14, color: AppColors.textTertiary),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: (_sending || _typewriterRunning) ? null : _send,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.4),
              ),
              icon: const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
