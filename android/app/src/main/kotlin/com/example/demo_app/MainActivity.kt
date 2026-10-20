package com.guguyu.gugu_bill

import android.accessibilityservice.AccessibilityServiceInfo
import android.content.ContentValues
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityManager
import android.Manifest
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    
    private val ACCESSIBILITY_CHANNEL = "com.aijizhang/accessibility"
    private val BACKUP_CHANNEL = "com.aijizhang/backup"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 设置FlutterEngine到MethodChannelWrapper供无障碍服务使用
        MethodChannelWrapper.flutterEngine = flutterEngine
        MethodChannelWrapper.initEventChannel(flutterEngine)
        
        // 注册无障碍服务事件通道
        AccessibilityEventChannel.register(flutterEngine)

        // 注册备份保存 MethodChannel（保存到公共 Downloads 目录）
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BACKUP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveToDownloads" -> {
                    val fileName = call.argument<String>("fileName")
                    val bytes = call.argument<ByteArray>("bytes")
                    val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                    if (fileName == null || bytes == null) {
                        result.error("ARG_ERROR", "缺少 fileName 或 bytes 参数", null)
                        return@setMethodCallHandler
                    }
                    val saved = saveBytesToDownloads(fileName, bytes, mimeType)
                    if (saved != null) {
                        result.success(saved)
                    } else {
                        result.error("SAVE_FAILED", "保存到公共 Downloads 失败", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 创建无障碍服务MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACCESSIBILITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityServiceEnabled" -> {
                    val enabled = checkAccessibilityServiceEnabled()
                    result.success(enabled)
                }
                
                "openAccessibilitySettings" -> {
                    try {
                        val intent = android.content.Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SETTINGS_ERROR", "无法打开无障碍设置: ${e.message}", null)
                    }
                }

                "requestPostNotificationsPermission" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1002)
                            result.success(true)
                        } else {
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.error("PERMISSION_ERROR", "请求通知权限失败: ${e.message}", null)
                    }
                }

                "hasPostNotificationsPermission" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            val granted = checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
                            result.success(granted)
                        } else {
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.error("PERMISSION_ERROR", "检查通知权限失败: ${e.message}", null)
                    }
                }
                
                "getAccessibilityServiceState" -> {
                    result.success(mapOf(
                        "isEnabled" to checkAccessibilityServiceEnabled(),
                        "serviceName" to "com.guguyu.gugu_bill/.BillAccessibilityService",
                        "isRunning" to (BillAccessibilityService.instance != null)
                    ))
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    /**
     * 检查无障碍服务是否启用
     */
    private fun checkAccessibilityServiceEnabled(): Boolean {
        val accessibilityManager = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        val enabledServices = accessibilityManager.getEnabledAccessibilityServiceList(
            AccessibilityServiceInfo.FEEDBACK_GENERIC
        )

        val serviceName = "com.guguyu.gugu_bill/.BillAccessibilityService"
        return enabledServices.any { it.id == serviceName }
    }

    /**
     * 把字节数组保存到公共 Downloads 目录（通过 MediaStore，Android 10+ 不需要权限）
     * @param fileName 文件名（不含路径）
     * @param bytes 文件内容
     * @param mimeType MIME 类型
     * @return 成功返回绝对路径，失败返回 null
     */
    private fun saveBytesToDownloads(fileName: String, bytes: ByteArray, mimeType: String): String? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+：使用 MediaStore Downloads，无需权限
                val resolver = contentResolver
                val values = ContentValues().apply {
                    put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                    put(MediaStore.Downloads.MIME_TYPE, mimeType)
                    put(MediaStore.Downloads.IS_PENDING, 1)
                }
                val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                    ?: return null
                resolver.openOutputStream(uri)?.use { it.write(bytes) }
                values.clear()
                values.put(MediaStore.Downloads.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
                // 返回 MediaStore 的相对路径（用户友好，跨 Android 版本一致）
                "${Environment.DIRECTORY_DOWNLOADS}/$fileName"
            } else {
                // Android 9 及以下：直接写外部存储
                val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                if (!downloadsDir.exists()) downloadsDir.mkdirs()
                val file = File(downloadsDir, fileName)
                file.writeBytes(bytes)
                file.absolutePath
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "saveBytesToDownloads failed: ${e.message}", e)
            null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        MethodChannelWrapper.dispose()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {
            1002 -> {
                val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
                Log.d("MainActivity", "通知权限请求结果: granted=$granted")
            }
        }
    }
}
