package com.guguyu.gugu_bill

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * 开机广播：若自动记账开关曾开启，则拉起前台保活服务。
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        Log.d(TAG, "收到广播: $action")

        when (action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON" -> {
                val anyOn = AutoRecordPrefs.anyEnabled(context)
                Log.d(
                    TAG,
                    "开机恢复检查 notification=${AutoRecordPrefs.isNotificationEnabled(context)} " +
                        "accessibility=${AutoRecordPrefs.isAccessibilityEnabled(context)}"
                )
                if (anyOn) {
                    AutoRecordKeepAliveService.start(context)
                    Log.d(TAG, "已请求启动自动记账保活服务")
                } else {
                    Log.d(TAG, "自动记账未开启，跳过保活")
                }
            }
        }
    }
}
