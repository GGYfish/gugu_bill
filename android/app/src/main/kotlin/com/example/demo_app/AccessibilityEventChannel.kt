package com.guguyu.gugu_bill

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

/**
 * EventChannel用于实时发送无障碍服务捕获的支付事件
 */
object AccessibilityEventChannel {
    
    private const val TAG = "AccessibilityEventChannel"
    private const val CHANNEL = "com.aijizhang/accessibility_event"
    
    private var eventSink: EventChannel.EventSink? = null
    private var eventChannel: EventChannel? = null
    
    /**
     * 注册EventChannel
     */
    fun register(flutterEngine: FlutterEngine) {
        try {
            eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            eventChannel?.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    Log.d(TAG, "EventChannel已连接")
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
    
    /**
     * 发送支付事件
     */
    fun sendPaymentEvent(data: Map<String, Any>) {
        try {
            eventSink?.success(data)
            Log.d(TAG, "发送支付事件成功: $data")
        } catch (e: Exception) {
            Log.e(TAG, "发送支付事件失败: ${e.message}")
        }
    }
}
