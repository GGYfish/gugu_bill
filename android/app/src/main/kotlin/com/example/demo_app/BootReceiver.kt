package com.guguyu.gugu_bill

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * 开机广播接收器
 * 用于在设备重启后提醒用户开启无障碍服务
 */
class BootReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "BootReceiver"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        
        Log.d(TAG, "收到广播: $action")
        
        // 开机广播处理（通知栏监听功能已移除，不再自动启动服务）
        when (action) {
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON" -> {
                Log.d(TAG, "设备已启动，请在应用中手动开启自动记账");
            }
        }
    }
}
