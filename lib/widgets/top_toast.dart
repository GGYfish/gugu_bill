import 'package:flutter/material.dart';

import '../ui_constants.dart';

/// 顶层提示浮层：直接插到根导航的 Overlay，最上层展示。
/// 显示在屏幕下方，用于底部弹窗（BottomSheet）内的校验提示，避免被 Sheet 盖住看不见。
class TopToast {
  TopToast._();

  static OverlayEntry? _entry;
  static int _seq = 0;

  static void show(BuildContext context, String message) {
    try {
      try {
        hide();
      } catch (_) {
        _entry = null;
      }
      NavigatorState? navigator;
      try {
        navigator = Navigator.of(context, rootNavigator: true);
      } catch (_) {
        navigator = null;
      }
      final overlay = navigator?.overlay;
      if (overlay == null) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } catch (_) {
          debugPrint('TopToast fallback failed: $message');
        }
        return;
      }
      double bottomPadding = 0;
      double keyboardHeight = 0;
      try {
        bottomPadding = MediaQuery.of(context).padding.bottom;
        // 键盘弹起时 viewInsets.bottom > 0，提示要顶到键盘上方，否则会被键盘盖住看起来像“没反应”
        keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      } catch (_) {
        bottomPadding = 0;
        keyboardHeight = 0;
      }
      final id = ++_seq;
      _entry = OverlayEntry(
        builder: (_) => Positioned(
          bottom: bottomPadding + keyboardHeight + 24,
          left: 16,
          right: 16,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.surface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      overlay.insert(_entry!);
      Future.delayed(const Duration(seconds: 2), () {
        if (id == _seq) hide();
      });
    } catch (e) {
      // 提示本身绝不能再抛异常（否则会盖掉真正的业务错误）
      debugPrint('TopToast.show failed: $e');
    }
  }

  static void hide() {
    try {
      _entry?.remove();
    } catch (_) {
      // overlay 已释放时 remove 会抛，忽略即可
    } finally {
      _entry = null;
    }
  }
}
