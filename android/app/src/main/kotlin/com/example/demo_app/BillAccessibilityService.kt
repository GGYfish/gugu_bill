package com.guguyu.gugu_bill

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/**
 * 无障碍服务 - 监听支付页面
 * 检测各类App的支付成功页面，提取金额信息
 */
class BillAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "BillAccessibilityService"
        
        // 需要监听的App列表（支持支付的主流应用）
        private val TARGET_PACKAGES = setOf(
            // 支付平台
            "com.tencent.mm",                   // 微信
            "com.eg.android.AlipayGphone",       // 支付宝
            "com.unionpay",                      // 云闪付
            
            // 电商购物
            "com.taobao.taobao4kotlin",          // 淘宝
            "com.taobao.taobao",                  // 淘宝
            "com.alibaba.android.aliunsi",        // 淘宝
            "com.jd.jrapp",                      // 京东金融
            "com.jingdong.app.mall",              // 京东
            "com.vivo.shop",                      // vivo商城
            "com.oppo.market",                    // OPPO商城
            "com.xiaomi.shop",                    // 小米商城
            "com.suning.mobile.epsp",             // 苏宁易购
            "com.dianping.v1",                    // 美团
            "com.sankuai.meituan",                // 美团
            "me.ele",                             // 饿了么
            "com.immomo.momo",                    // 陌陌购物
            "com.baidu.baike",                    // 百度糯米
            "com.wudao.app",                      // 拼多多（部分版本）
            "com.xunmeng.pinduoduo",              // 拼多多
            "com.xunmeng.jinli",                  // 拼多多
            "com.jinxiang.mc",                    // 拼多多
            "com.taobao.ucos",                    // 淘特
            "com.yaya",                           // 唯品会
            "com.ushaqi.lite",                    // 唯品会
            "com.xl.music",                       // QQ音乐
            
            // 外卖
            "com.sankuai.meituanfood",            // 美团外卖
            "com.ele.websocket",                   // 饿了么
            
            // 出行
            "com.sdu.didi.psnger",                // 滴滴出行
            "com.didi.espass",                    // 滴滴
            "com.ctrip.byhip",                    // 携程
            "com.mogujie",                        // 蘑菇街
            
            // 生活服务
            "com.wuyeapp",                        // 物业缴费
            "com.jfshare",                        // 集分宝
            "com.baidu.minivent",                 // 百度有钱花
            "com.antfortune.wealth",              // 蚂蚁财富
            "com.alipay.ant.money",               // 蚂蚁星愿
            "com.alipay.education",                // 蚂蚁教育
            
            // 视频会员
            "com.qiyi.video",                     // 爱奇艺
            "com.tencent.qqlive",                 // 腾讯视频
            "com.youku.phone",                    // 优酷
            "com.baidu.video",                    // 百度视频
            "com.pplive.android",                 // PP视频
            
            // 游戏
            "com.tencent.game.rhino.hg",          // 王者荣耀充值
            "com.tencent.tmgp.sgame",             // 王者荣耀
            "com.netease.g40",                    // 网易游戏
            
            // 共享经济
            "com.ofo.loofo",                      // ofo小黄车
            "com.gotoke",                         // 街电
            "com.mogujie.emeixin",                // 美丽说
        )
        
        // 支付成功的关键词（用于识别支付成功页面）
        private val PAYMENT_SUCCESS_KEYWORDS = listOf(
            "支付成功", "支付完成", "已支付", "支付¥", "付款成功", "支付￥",
            "转账成功", "收款成功", "交易成功", "购买成功", "充值成功",
            "付款金额", "实付金额", "订单金额", "消费金额", "¥", "￥",
            "下单成功", "下单完成", "下单支付"
        )
        
        // 金额正则表达式
        private val AMOUNT_REGEX = Regex("[¥￥]?\\s*(\\d+\\.?\\d{0,2})\\s*[元]?")
        
        var instance: BillAccessibilityService? = null
            private set
    }

    private val methodChannel = MethodChannelWrapper()

    override fun onCreate() {
        super.onCreate()
        instance = this
        Log.d(TAG, "无障碍服务创建")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        Log.d(TAG, "无障碍服务销毁")
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or 
                         AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_REQUEST_ENHANCED_WEB_ACCESSIBILITY
            notificationTimeout = 100
        }
        
        serviceInfo = info
        Log.d(TAG, "无障碍服务已连接")
        
        // 通知Dart层服务已启动
        methodChannel.sendServiceState(this, true)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        
        val packageName = event.packageName?.toString() ?: return
        
        // 只处理目标App
        if (packageName !in TARGET_PACKAGES) {
            return
        }
        
        Log.d(TAG, "收到事件: $packageName, 类型: ${event.eventType}")
        
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                handleWindowStateChanged(event, packageName)
            }
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                handleContentChanged(event, packageName)
            }
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "无障碍服务被中断")
        methodChannel.sendServiceState(this, false)
    }

    /**
     * 窗口状态变化（页面切换）
     */
    private fun handleWindowStateChanged(event: AccessibilityEvent, packageName: String) {
        val className = event.className?.toString() ?: ""
        
        Log.d(TAG, "窗口变化: $className")
        
        // 统一使用通用检测方法
        detectPayment(event, packageName)
    }

    /**
     * 内容变化（页面内更新）
     */
    private fun handleContentChanged(event: AccessibilityEvent, packageName: String) {
        // 延迟检查，等内容加载完成
        android.os.Handler(mainLooper).postDelayed({
            detectPayment(event, packageName)
        }, 500)
    }
    
    /**
     * 通用支付检测方法
     */
    private fun detectPayment(event: AccessibilityEvent, packageName: String) {
        val rootNode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            event.source
        } else {
            @Suppress("DEPRECATION")
            event.source
        } ?: return

        try {
            // 获取App显示名称
            val appDisplayName = getAppDisplayName(packageName)
            
            // 递归遍历节点查找支付成功相关信息
            val paymentInfo = findPaymentInfo(rootNode, appDisplayName)
            
            if (paymentInfo != null) {
                Log.d(TAG, "检测到支付: $appDisplayName - $paymentInfo")
                methodChannel.sendPaymentInfo(
                    context = this,
                    appName = appDisplayName,
                    amount = paymentInfo.first,
                    detail = paymentInfo.second
                )
            }
        } finally {
            rootNode.recycle()
        }
    }
    
    /**
     * 根据包名获取App显示名称
     */
    private fun getAppDisplayName(packageName: String): String {
        return when (packageName) {
            // 支付平台
            "com.tencent.mm" -> "微信支付"
            "com.eg.android.AlipayGphone" -> "支付宝"
            "com.unionpay" -> "云闪付"
            
            // 电商购物
            "com.taobao.taobao4kotlin", "com.taobao.taobao", "com.alibaba.android.aliunsi" -> "淘宝"
            "com.jd.jrapp", "com.jingdong.app.mall" -> "京东"
            "com.vivo.shop" -> "vivo商城"
            "com.oppo.market" -> "OPPO商城"
            "com.xiaomi.shop" -> "小米商城"
            "com.suning.mobile.epsp" -> "苏宁易购"
            "com.dianping.v1", "com.sankuai.meituan", "com.sankuai.meituanfood" -> "美团"
            "me.ele", "com.ele.websocket" -> "饿了么"
            "com.xunmeng.pinduoduo", "com.xunmeng.jinli", "com.jinxiang.mc", "com.wudao.app" -> "拼多多"
            "com.taobao.ucos" -> "淘特"
            "com.yaya", "com.ushaqi.lite" -> "唯品会"
            "com.baidu.baike" -> "百度糯米"
            
            // 出行
            "com.sdu.didi.psnger", "com.didi.espass" -> "滴滴出行"
            "com.ctrip.byhip" -> "携程"
            
            // 生活服务
            "com.baidu.minivent" -> "百度有钱花"
            "com.antfortune.wealth" -> "蚂蚁财富"
            "com.alipay.ant.money" -> "蚂蚁星愿"
            "com.alipay.education" -> "蚂蚁教育"
            "com.jfshare" -> "集分宝"
            
            // 视频会员
            "com.qiyi.video" -> "爱奇艺"
            "com.tencent.qqlive" -> "腾讯视频"
            "com.youku.phone" -> "优酷"
            "com.baidu.video" -> "百度视频"
            "com.pplive.android" -> "PP视频"
            "com.xl.music" -> "QQ音乐"
            
            // 游戏
            "com.tencent.game.rhino.hg", "com.tencent.tmgp.sgame" -> "王者荣耀"
            "com.netease.g40" -> "网易游戏"
            
            // 其他
            "com.immomo.momo" -> "陌陌"
            "com.mogujie", "com.mogujie.emeixin" -> "蘑菇街"
            "com.ofo.loofo" -> "ofo"
            "com.gotoke" -> "街电"
            
            else -> packageName.substringAfterLast('.')
        }
    }

    /**
     * 从节点树中查找支付信息
     * @return Pair<金额, 详情>
     */
    private fun findPaymentInfo(node: AccessibilityNodeInfo, appName: String): Pair<Double, String>? {
        val text = node.text?.toString() ?: ""
        val contentDesc = node.contentDescription?.toString() ?: ""
        
        // 查找金额
        val amountRegex = Regex("[¥￥]?\\s*(\\d+\\.?\\d*)\\s*[元]?")
        
        // 检查当前节点
        val fullText = "$text $contentDesc"
        
        // 匹配金额
        val amountMatch = amountRegex.find(fullText)
        if (amountMatch != null) {
            val amountStr = amountMatch.groupValues[1]
            val amount = amountStr.toDoubleOrNull() ?: return null
            
            // 金额大于0且小于100万（排除异常值）
            if (amount > 0 && amount < 1000000) {
                // 查找支付成功标识
                val successIndicators = listOf(
                    "支付成功", "已支付", "支付完成", "收款成功", 
                    "交易成功", "成功", "付款成功", "转账成功"
                )
                
                val hasSuccessIndicator = successIndicators.any { 
                    fullText.contains(it) 
                }
                
                // 如果没有成功标识，检查是否是金额页面（包含¥符号）
                if (hasSuccessIndicator || fullText.contains("¥") || fullText.contains("￥")) {
                    // 尝试获取商户名称
                    val detail = extractDetail(node, appName)
                    return Pair(amount, detail)
                }
            }
        }
        
        // 递归检查子节点
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            try {
                val result = findPaymentInfo(child, appName)
                if (result != null) {
                    return result
                }
            } finally {
                child.recycle()
            }
        }
        
        return null
    }

    /**
     * 提取交易详情
     */
    private fun extractDetail(node: AccessibilityNodeInfo, appName: String): String {
        val texts = mutableListOf<String>()
        
        // 收集所有文本
        collectTexts(node, texts)
        
        // 过滤并组合有意义的文本
        val relevantTexts = texts.filter { text ->
            text.isNotBlank() && 
            text.length > 1 &&
            text.length < 50 &&
            !text.matches(Regex("^[¥￥]$")) &&
            !text.matches(Regex("^\\d+$"))
        }
        
        // 返回组合的详情
        return if (relevantTexts.isNotEmpty()) {
            "$appName - ${relevantTexts.take(3).joinToString(" ")}"
        } else {
            "$appName 支付"
        }
    }

    /**
     * 收集节点的所有文本
     */
    private fun collectTexts(node: AccessibilityNodeInfo, texts: MutableList<String>) {
        val text = node.text?.toString()
        if (!text.isNullOrBlank()) {
            texts.add(text.trim())
        }
        
        val desc = node.contentDescription?.toString()
        if (!desc.isNullOrBlank()) {
            texts.add(desc.trim())
        }
        
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            try {
                collectTexts(child, texts)
            } finally {
                child.recycle()
            }
        }
    }
}
