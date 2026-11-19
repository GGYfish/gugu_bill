package com.guguyu.gugu_bill

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.view.accessibility.AccessibilityWindowInfo
import com.guguyu.gugu_bill.parser.PaymentAppParser
import com.guguyu.gugu_bill.parser.PinduoduoPaymentParser

/**
 * 无障碍自动记账：按 App 逐个适配解析器。
 * 当前已适配：拼多多。日志只保留关键结果，避免刷屏。
 */
class BillAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "BillAccessibility"

        var instance: BillAccessibilityService? = null
            private set

        private val PARSERS: Map<String, PaymentAppParser> = listOf(
            PinduoduoPaymentParser(),
        ).associateBy { it.packageName }

        /** 成功页停留反复扫描时的短时去重窗口 */
        private const val DEDUPE_MS = 180_000L
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val pendingTasks = mutableListOf<Runnable>()
    private var lastSchedulePkg: String? = null
    private var lastScheduleAt = 0L
    private var lastReportKey: String? = null
    private var lastReportAt = 0L

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.i(TAG, "无障碍服务启动 quiet=1 已适配=${PARSERS.values.map { it.appName }}")
    }

    override fun onDestroy() {
        clearPending()
        instance = null
        Log.i(TAG, "无障碍服务销毁")
        super.onDestroy()
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        val info = serviceInfo
        if (info != null) {
            info.eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                AccessibilityEvent.TYPE_WINDOWS_CHANGED
            info.feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            info.flags = info.flags or
                AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS or
                AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
            info.notificationTimeout = 100
            info.packageNames = PARSERS.keys.toTypedArray()
            serviceInfo = info
        }
        Log.i(TAG, "无障碍服务已连接")
    }

    override fun onInterrupt() {}

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        val pkg = event.packageName?.toString() ?: return
        if (pkg !in PARSERS) return
        val className = event.className?.toString().orEmpty()

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOWS_CHANGED -> {
                scheduleMultiScan(pkg, className, light = false)
            }
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                scheduleMultiScan(pkg, className, light = true)
            }
        }
    }

    private fun clearPending() {
        pendingTasks.forEach { mainHandler.removeCallbacks(it) }
        pendingTasks.clear()
    }

    private fun scheduleMultiScan(
        packageName: String,
        className: String,
        light: Boolean,
    ) {
        val now = System.currentTimeMillis()
        if (light && packageName == lastSchedulePkg && now - lastScheduleAt < 1000) {
            return
        }
        lastSchedulePkg = packageName
        lastScheduleAt = now
        clearPending()

        val delays = if (light) listOf(600L, 1400L) else listOf(400L, 1000L, 2000L)
        for (delay in delays) {
            val task = Runnable { scanWithParser(packageName, className) }
            pendingTasks.add(task)
            mainHandler.postDelayed(task, delay)
        }
    }

    private fun scanWithParser(packageName: String, className: String) {
        val parser = PARSERS[packageName] ?: return
        val roots = collectRootNodes()
        if (roots.isEmpty()) return

        try {
            val texts = mutableListOf<String>()
            for (root in roots) {
                collectTexts(root, texts, depth = 0)
            }
            if (texts.isEmpty()) return

            val joined = texts.joinToString(" ")
            parser.observePage(texts, joined)
            if (!parser.looksLikeSuccessPage(texts, joined)) return

            val result = parser.parse(texts, joined, className) ?: return
            // 金额 + 备注 一起去重，避免成功页刷屏重复上报
            val key =
                "${packageName}_${"%.2f".format(result.amount)}_${result.detail}"
            val now = System.currentTimeMillis()
            if (key == lastReportKey && now - lastReportAt < DEDUPE_MS) {
                Log.d(TAG, "短时去重跳过 key=$key")
                return
            }
            lastReportKey = key
            lastReportAt = now
            clearPending()

            AccessibilityEventChannel.sendPaymentEvent(
                mapOf(
                    "appName" to result.appName,
                    "amount" to result.amount,
                    "detail" to result.detail,
                    "timestamp" to now,
                    "source" to "accessibility",
                    "packageName" to packageName,
                    "isIncome" to result.isIncome,
                    "className" to className,
                ),
            )
            Log.e(
                TAG,
                "记账 ${result.appName} ¥${result.amount} ${result.keyword} | ${result.detail}",
            )
        } catch (e: Exception) {
            Log.e(TAG, "扫描失败: ${e.message}", e)
        } finally {
            roots.forEach { n ->
                try {
                    n.recycle()
                } catch (_: Exception) {
                }
            }
        }
    }

    private fun collectRootNodes(): List<AccessibilityNodeInfo> {
        val list = mutableListOf<AccessibilityNodeInfo>()
        rootInActiveWindow?.let { list.add(it) }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                windows?.forEach { w ->
                    if (w.type == AccessibilityWindowInfo.TYPE_APPLICATION ||
                        w.type == AccessibilityWindowInfo.TYPE_SYSTEM
                    ) {
                        val root = w.root ?: return@forEach
                        if (list.none { it == root }) list.add(root)
                    }
                }
            } catch (_: Exception) {
            }
        }
        return list
    }

    private fun collectTexts(node: AccessibilityNodeInfo?, out: MutableList<String>, depth: Int) {
        if (node == null || depth > 50) return
        val t = node.text?.toString()?.trim()
        if (!t.isNullOrEmpty()) out.add(if (t.length > 200) t.take(200) else t)
        val d = node.contentDescription?.toString()?.trim()
        if (!d.isNullOrEmpty() && d != t) {
            out.add(if (d.length > 200) d.take(200) else d)
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            try {
                collectTexts(child, out, depth + 1)
            } finally {
                try {
                    child.recycle()
                } catch (_: Exception) {
                }
            }
        }
    }
}
