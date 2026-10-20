package com.guguyu.gugu_bill

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * 无障碍服务与Dart通信的MethodChannel包装类
 */
class MethodChannelWrapper {
    
    companion object {
        private const val TAG = "MethodChannelWrapper"
        private const val CHANNEL = "com.aijizhang/accessibility"
        
        // 静态引用FlutterEngine，由Flutter端设置
        var flutterEngine: FlutterEngine? = null
            set(value) {
                field = value
                Log.d(TAG, "FlutterEngine已设置")
            }
        
        // EventChannel用于发送支付事件
        private var eventSink: EventChannel.EventSink? = null
        
        /**
         * 初始化EventChannel
         */
        fun initEventChannel(engine: FlutterEngine) {
            val eventChannel = EventChannel(engine.dartExecutor.binaryMessenger, "com.aijizhang/accessibility_events")
            eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    Log.d(TAG, "EventChannel监听已建立")
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
        }
        
        /**
         * 释放资源
         */
        fun dispose() {
            eventSink = null
            flutterEngine = null
            Log.d(TAG, "MethodChannelWrapper资源已释放")
        }
    }
    
    /**
     * 发送无障碍服务状态
     */
    fun sendServiceState(service: BillAccessibilityService, isRunning: Boolean) {
        try {
            val engine = flutterEngine ?: run {
                Log.w(TAG, "FlutterEngine未设置，无法发送服务状态")
                return
            }
            val channel = MethodChannel(
                engine.dartExecutor.binaryMessenger,
                CHANNEL
            )
            
            channel.invokeMethod("onServiceStateChanged", mapOf(
                "isRunning" to isRunning,
                "serviceName" to "BillAccessibilityService"
            ))
            
            Log.d(TAG, "发送服务状态: $isRunning")
        } catch (e: Exception) {
            Log.e(TAG, "发送服务状态失败: ${e.message}")
        }
    }
    
    /**
     * 发送支付信息到Dart层
     */
    fun sendPaymentInfo(
        context: Context,
        appName: String,
        amount: Double,
        detail: String
    ) {
        try {
            // 通过EventChannel发送，避免阻塞
            val eventData = mapOf(
                "appName" to appName,
                "amount" to amount,
                "detail" to detail,
                "timestamp" to System.currentTimeMillis(),
                "source" to "accessibility"
            )
            
            eventSink?.success(eventData)
                ?: AccessibilityEventChannel.sendPaymentEvent(eventData)
            
            Log.d(TAG, "发送支付信息: $appName ¥$amount")
        } catch (e: Exception) {
            Log.e(TAG, "发送支付信息失败: ${e.message}")
        }
    }
}
