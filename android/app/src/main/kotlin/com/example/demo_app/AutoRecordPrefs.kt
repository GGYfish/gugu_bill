package com.guguyu.gugu_bill

import android.content.Context

/**
 * 原生侧保存自动记账开关，供开机广播读取（不依赖 Flutter 是否已启动）
 */
object AutoRecordPrefs {
    private const val PREF = "auto_record_prefs"
    private const val KEY_NOTIFICATION = "notification_enabled"
    private const val KEY_ACCESSIBILITY = "accessibility_enabled"

    fun sync(context: Context, notification: Boolean, accessibility: Boolean) {
        context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_NOTIFICATION, notification)
            .putBoolean(KEY_ACCESSIBILITY, accessibility)
            .apply()
    }

    fun isNotificationEnabled(context: Context): Boolean =
        context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
            .getBoolean(KEY_NOTIFICATION, false)

    fun isAccessibilityEnabled(context: Context): Boolean =
        context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
            .getBoolean(KEY_ACCESSIBILITY, false)

    fun anyEnabled(context: Context): Boolean =
        isNotificationEnabled(context) || isAccessibilityEnabled(context)
}
