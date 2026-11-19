package com.guguyu.gugu_bill

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * 前台常驻服务：提升进程优先级，配合通知监听 / 无障碍在后台保活。
 * 开机后由 BootReceiver 按开关状态拉起。
 */
class AutoRecordKeepAliveService : Service() {

    companion object {
        private const val TAG = "AutoRecordKeepAlive"
        private const val CHANNEL_ID = "auto_record_keepalive"
        private const val NOTIFICATION_ID = 2001

        const val ACTION_START = "com.guguyu.gugu_bill.action.START_KEEPALIVE"
        const val ACTION_STOP = "com.guguyu.gugu_bill.action.STOP_KEEPALIVE"

        fun start(context: Context) {
            val intent = Intent(context, AutoRecordKeepAliveService::class.java).apply {
                action = ACTION_START
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (e: Exception) {
                Log.e(TAG, "启动保活服务失败: ${e.message}", e)
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, AutoRecordKeepAliveService::class.java).apply {
                action = ACTION_STOP
            }
            try {
                context.startService(intent)
            } catch (_: Exception) {
                context.stopService(Intent(context, AutoRecordKeepAliveService::class.java))
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        ensureChannel()
        Log.d(TAG, "保活服务 onCreate")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                Log.d(TAG, "收到停止指令")
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
                return START_NOT_STICKY
            }
            else -> {
                if (!AutoRecordPrefs.anyEnabled(this)) {
                    Log.d(TAG, "开关均未开启，不保活")
                    stopForeground(STOP_FOREGROUND_REMOVE)
                    stopSelf()
                    return START_NOT_STICKY
                }
                promoteToForeground()
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        Log.d(TAG, "保活服务 onDestroy")
        super.onDestroy()
    }

    private fun promoteToForeground() {
        val notification = buildNotification()
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
                )
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
            Log.d(TAG, "已进入前台保活")
        } catch (e: Exception) {
            Log.e(TAG, "startForeground 失败，降级普通通知: ${e.message}", e)
            try {
                startForeground(NOTIFICATION_ID, notification)
            } catch (e2: Exception) {
                Log.e(TAG, "降级 startForeground 仍失败: ${e2.message}", e2)
            }
        }
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            "自动记账保活",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "保持自动记账在后台运行"
            setShowBadge(false)
        }
        manager.createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val modes = buildList {
            if (AutoRecordPrefs.isNotificationEnabled(this@AutoRecordKeepAliveService)) add("通知栏")
            if (AutoRecordPrefs.isAccessibilityEnabled(this@AutoRecordKeepAliveService)) add("无障碍")
        }.joinToString(" + ").ifEmpty { "守护中" }

        val launch = packageManager.getLaunchIntentForPackage(packageName)
            ?: Intent(this, MainActivity::class.java)
        launch.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val pendingFlags = PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
        val pi = PendingIntent.getActivity(this, 0, launch, pendingFlags)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("咕咕鱼自动记账运行中")
            .setContentText("已开启：$modes")
            .setOngoing(true)
            .setShowWhen(false)
            .setContentIntent(pi)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }
}
