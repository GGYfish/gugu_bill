package com.guguyu.gugu_bill

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/**
 * EventChannel：通知栏支付事件 → Dart
 */
object NotificationEventChannel {

    private const val TAG = "NotificationEventChannel"
    private const val CHANNEL = "com.aijizhang/notification_event"

    private var eventSink: EventChannel.EventSink? = null
    private val pendingEvents = mutableListOf<Map<String, Any>>()

    fun register(flutterEngine: FlutterEngine) {
        try {
            EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setStreamHandler(object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        eventSink = events
                        Log.d(TAG, "EventChannel已连接")
                        // 补发缓存事件
                        if (pendingEvents.isNotEmpty()) {
                            val copy = pendingEvents.toList()
                            pendingEvents.clear()
                            copy.forEach { events?.success(it) }
                        }
                    }

                    override fun onCancel(arguments: Any?) {
                        eventSink = null
                        Log.d(TAG, "EventChannel已断开")
                    }
                })
        } catch (e: Exception) {
            Log.e(TAG, "注册EventChannel失败: ${e.message}")
        }
    }

    fun sendPaymentEvent(data: Map<String, Any>) {
        try {
            val sink = eventSink
            if (sink != null) {
                sink.success(data)
                Log.d(TAG, "发送通知支付事件: $data")
            } else {
                pendingEvents.add(data)
                if (pendingEvents.size > 30) {
                    pendingEvents.removeAt(0)
                }
                Log.d(TAG, "EventSink为空，已缓存事件 size=${pendingEvents.size}")
            }
        } catch (e: Exception) {
            Log.e(TAG, "发送通知支付事件失败: ${e.message}")
        }
    }
}
