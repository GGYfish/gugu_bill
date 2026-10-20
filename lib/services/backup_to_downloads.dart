import 'package:flutter/services.dart';

/// 把备份文件保存到公共 Downloads 目录的原生桥接。
///
/// Android 10+ 通过 MediaStore 实现，不需要任何运行时权限；
/// Android 9 及以下需要 `WRITE_EXTERNAL_STORAGE` 权限。
///
/// 调用失败（如 iOS 平台、非 Android 环境）返回 null，
/// 调用方应回退到 app 沙箱 + 系统分享面板。
class BackupToDownloads {
  BackupToDownloads._();

  static const MethodChannel _channel = MethodChannel('com.aijizhang/backup');

  /// 把字节数组保存到公共 Downloads 目录。
  /// @return 成功返回绝对路径，失败返回 null。
  static Future<String?> saveToDownloads({
    required String fileName,
    required Uint8List bytes,
    String mimeType = 'application/octet-stream',
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('saveToDownloads', {
        'fileName': fileName,
        'bytes': bytes,
        'mimeType': mimeType,
      });
      return result;
    } on MissingPluginException {
      // 非 Android 平台 / 单元测试环境
      return null;
    } on PlatformException {
      return null;
    }
  }
}
