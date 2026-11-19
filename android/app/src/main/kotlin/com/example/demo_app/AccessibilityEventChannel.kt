package com.guguyu.gugu_bill

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/**
 * 无障碍支付事件 → Dart
 */
object AccessibilityEventChannel {

    private const val TAG = "AccessibilityEventChannel"
    private const val CHANNEL = "com.aijizhang/accessibility_event"

    private var eventSink: EventChannel.EventSink? = null
    private val pendingEvents = mutableListOf<Map<String, Any>>()

    fun register(flutterEngine: FlutterEngine) {
        try {
            EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setStreamHandler(object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        eventSink = events
                        Log.d(TAG, "EventChannel 已连接")
                        if (pendingEvents.isNotEmpty()) {
                            val copy = pendingEvents.toList()
                            pendingEvents.clear()
                            copy.forEach { events?.success(it) }
                        }
                    }

                    override fun onCancel(arguments: Any?) {
                        eventSink = null
                        Log.d(TAG, "EventChannel 已断开")
                    }
                })
        } catch (e: Exception) {
            Log.e(TAG, "注册失败: ${e.message}")
        }
    }

    fun sendPaymentEvent(data: Map<String, Any>) {
        try {
            val sink = eventSink
            if (sink != null) {
                sink.success(data)
                Log.d(TAG, "发送支付事件: $data")
            } else {
                pendingEvents.add(data)
                if (pendingEvents.size > 30) pendingEvents.removeAt(0)
                Log.d(TAG, "EventSink 为空，已缓存 size=${pendingEvents.size}")
            }
        } catch (e: Exception) {
            Log.e(TAG, "发送失败: ${e.message}")
        }
    }
}
