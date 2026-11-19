package com.guguyu.gugu_bill

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
/**
 * 通知栏监听：解析支付/收款类通知，推送到 Flutter 静默记账
 */
class BillNotificationListenerService : NotificationListenerService() {

    companion object {
        private const val TAG = "BillNotificationListener"

        var instance: BillNotificationListenerService? = null
            private set

        private val TARGET_PACKAGES = setOf(
            "com.tencent.mm",                    // 微信
            "com.eg.android.AlipayGphone",       // 支付宝
            "com.unionpay",                      // 云闪付
            "com.jingdong.app.mall",             // 京东
            "com.xunmeng.pinduoduo",             // 拼多多
            "com.sankuai.meituan",               // 美团
            "me.ele",                           // 饿了么
            "com.taobao.taobao",                 // 淘宝
            "com.chinamworld.main",             // 工行
            "com.android.bankabc",              // 农行
            "com.chinamworld.bocmbci",          // 中行
            "com.icbc",                         // 工行旧包名
            "cmb.pb",                           // 招行
            "com.cmbchina.ccd.pluto.cmbActivity",
            "com.pingan.paces.ccms",            // 平安
            "cn.com.cmbc.newmbank",             // 民生
            "com.yitong.mbank.psbc",            // 邮储
            "com.bankcomm.Bankcomm",            // 交行
        )

        private val APP_NAMES = mapOf(
            "com.tencent.mm" to "微信",
            "com.eg.android.AlipayGphone" to "支付宝",
            "com.unionpay" to "云闪付",
            "com.jingdong.app.mall" to "京东",
            "com.xunmeng.pinduoduo" to "拼多多",
            "com.sankuai.meituan" to "美团",
            "me.ele" to "饿了么",
            "com.taobao.taobao" to "淘宝",
        )

        private val PAYMENT_KEYWORDS = listOf(
            "支付成功", "付款成功", "已支付", "交易成功", "消费成功",
            "支付完成", "付款完成", "已付款", "扣款成功", "成功支付",
            "支出", "消费", "付款", "支付了", "向商户付款",
            "收款成功", "收款到账", "已收款", "收到转账", "到账",
            "转入", "入账", "转账成功", "红包", "退款成功", "已退款"
        )

        private val INCOME_KEYWORDS = listOf(
            "收款", "到账", "转入", "入账", "收到", "红包", "退款"
        )

        private val AMOUNT_REGEX = Regex("""[¥￥]\s*(\d+(?:\.\d{1,2})?)|(\d+(?:\.\d{1,2})?)\s*元""")
    }

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.d(TAG, "通知监听服务创建")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        Log.d(TAG, "通知监听服务销毁")
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d(TAG, "通知监听已连接")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return
        try {
            handleNotification(sbn)
        } catch (e: Exception) {
            Log.e(TAG, "处理通知失败: ${e.message}", e)
        }
    }

    private fun handleNotification(sbn: StatusBarNotification) {
        val pkg = sbn.packageName ?: return
        if (pkg !in TARGET_PACKAGES) return

        val extras = sbn.notification?.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString().orEmpty()
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString().orEmpty()
        val content = listOf(title, text, bigText).filter { it.isNotBlank() }.joinToString(" ")
        if (content.isBlank()) return

        // 是否像支付相关通知
        if (PAYMENT_KEYWORDS.none { content.contains(it) }) return
        // 排除额度类文案
        if (content.contains("可用额度") || content.contains("剩余额度")) return

        val amount = extractAmount(content) ?: return
        if (amount <= 0 || amount > 1_000_000) return

        val isIncome = INCOME_KEYWORDS.any { content.contains(it) }
        val now = System.currentTimeMillis()
        val appName = APP_NAMES[pkg] ?: pkg
        val detail = content.take(120)

        val eventData = mapOf(
            "appName" to appName,
            "amount" to amount,
            "detail" to detail,
            "timestamp" to now,
            "source" to "notification",
            "packageName" to pkg,
            "isIncome" to isIncome,
        )

        Log.d(TAG, "解析到支付通知: $appName ¥$amount income=$isIncome")
        NotificationEventChannel.sendPaymentEvent(eventData)
    }

    private fun extractAmount(text: String): Double? {
        val match = AMOUNT_REGEX.find(text) ?: return null
        val raw = match.groupValues[1].ifBlank { match.groupValues[2] }
        return raw.toDoubleOrNull()
    }
}
