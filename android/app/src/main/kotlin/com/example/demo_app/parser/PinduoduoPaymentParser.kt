package com.guguyu.gugu_bill.parser

import android.util.Log

/**
 * 拼多多（com.xunmeng.pinduoduo）支付成功页适配。
 *
 * - 详情页（店铺+收藏+客服）缓存商品标题
 * - 规格弹层缓存「已选：」规格 + 带 ¥ 的金额
 * - 记账备注格式：标题：xx（换行）规格：xx
 */
class PinduoduoPaymentParser : PaymentAppParser {

    override val packageName: String = "com.xunmeng.pinduoduo"
    override val appName: String = "拼多多"

    @Volatile
    private var cachedProductTitle: String? = null

    @Volatile
    private var cachedSelected: String? = null

    /** 选规格时缓存的金额：仅当成功页匹配关键字但抽不到金额时兜底使用 */
    @Volatile
    private var cachedAmount: Double? = null

    companion object {
        // 与无障碍服务同 TAG，方便 logcat 只滤 BillAccessibility 也能看到
        private const val TAG = "BillAccessibility"

        private val SUCCESS_KEYWORDS = listOf(
            "支付成功",
            "付款成功",
            "购买成功",
            "交易成功",
            "支付完成",
            "付款完成",
            "已支付成功",
            "已支付",
            "拼单成功",
            "下单成功",
            "订单支付成功",
        )

        /**
         * 订单操作区硬拦截：出现任一则一律不记账
         *（即使同时有「拼单成功 / 已支付」等成功词）
         */
        private val NEVER_RECORD_KEYWORDS = listOf(
            "申请退款",
            "再次拼单",
            "催发货",
            "查看物流",
            "确认收货",
            "评价晒单",
            "删除订单",
        )

        private val BLOCK_KEYWORDS = listOf(
            "发起了拼单",
            "在等你一起拼",
            "商品主图",
            "减少数量",
            "增加数量",
            "已选:",
            "已选：",
            "确认收货后再付款",
            "支持0元下单",
            "立即支付",
            "提交订单",
            "确认订单",
            "选择规格",
            "加入购物车",
            "领券购买",
            "限量低价",
            "可参与拼单",
            "直接拼成",
        )

        /** 详情页三件套 */
        private val DETAIL_MARKERS = listOf("店铺", "收藏", "客服")

        private val TITLE_NOISE = listOf(
            "返回", "关闭", "分享", "客服", "首页", "消息", "个人中心",
            "包邮", "退货", "发货", "收藏", "店铺", "评价", "详情",
            "规格", "数量", "减少", "增加", "已选", "拼单", "优惠券",
            "查看订单", "返回首页", "继续逛", "支付", "付款", "下单",
            "收货", "地址", "地铁", "栋", "单元", "好评", "热销",
        )

        private val SELECTED_PREFIX = Regex("""已选\s*[:：]\s*(.+)""")

        // ¥ / ￥ 后允许夹杂无障碍拆开的 "|" 
        private val YUAN_AMOUNT = Regex("""[¥￥]\s*[|｜]?\s*(\d+(?:\.\d{1,2})?)""")

        private val LABELED_AMOUNT = listOf(
            Regex("""实付款?\s*[:：]?\s*[¥￥]\s*[|｜]?\s*(\d+(?:\.\d{1,2})?)"""),
            Regex("""合计\s*[:：]?\s*[¥￥]\s*[|｜]?\s*(\d+(?:\.\d{1,2})?)"""),
            Regex("""(?:支付|付款)金额\s*[:：]?\s*[¥￥]\s*[|｜]?\s*(\d+(?:\.\d{1,2})?)"""),
            Regex("""(?:商品价格|券后价|券后|现价|到手价)\s*[:：]?\s*[¥￥]\s*[|｜]?\s*(\d+(?:\.\d{1,2})?)"""),
            YUAN_AMOUNT,
        )
    }

    override fun observePage(texts: List<String>, joined: String) {
        if (SUCCESS_KEYWORDS.any { joined.contains(it) }) return

        // 1) 规格：有「已选：」就缓存规格 + 金额
        extractSelected(texts, joined)?.let { selected ->
            val amount = extractAmountNearSelected(texts, joined)
            val selectedChanged = selected != cachedSelected
            val amountChanged = amount != null && amount != cachedAmount
            if (selectedChanged || amountChanged) {
                cachedSelected = selected
                if (amount != null && amount > 0) {
                    cachedAmount = amount
                }
                Log.e(TAG, "缓存规格: $selected")
                if (cachedAmount != null) {
                    Log.e(TAG, "缓存金额: ¥$cachedAmount")
                }
                Log.e(TAG, "当前备注预览: ${buildDetail()}")
            }
        }

        // 2) 标题：详情页三件套同时出现才缓存
        if (DETAIL_MARKERS.all { joined.contains(it) }) {
            extractProductTitle(texts)?.let { title ->
                if (title != cachedProductTitle) {
                    cachedProductTitle = title
                    Log.e(TAG, "缓存标题: $title")
                    Log.e(TAG, "当前备注预览: ${buildDetail()}")
                }
            }
        }
    }

    override fun looksLikeSuccessPage(texts: List<String>, joined: String): Boolean {
        if (NEVER_RECORD_KEYWORDS.any { joined.contains(it) }) return false
        if (BLOCK_KEYWORDS.any { joined.contains(it) }) return false
        return SUCCESS_KEYWORDS.any { joined.contains(it) }
    }

    override fun parse(
        texts: List<String>,
        joined: String,
        className: String,
    ): PaymentParseResult? {
        // 订单操作字样：一律不记账
        if (NEVER_RECORD_KEYWORDS.any { joined.contains(it) }) return null
        if (BLOCK_KEYWORDS.any { joined.contains(it) }) return null
        val keyword = SUCCESS_KEYWORDS.firstOrNull { joined.contains(it) } ?: return null
        // 成功页先抽金额；抽不到（或 ≤0）再用规格页缓存金额
        val pageAmount = extractAmount(joined, keyword)
            ?.takeIf { it > 0.0 && it <= 100_000.0 }
        val amount = pageAmount
            ?: cachedAmount?.takeIf { it > 0.0 && it <= 100_000.0 }
            ?: return null

        return PaymentParseResult(
            appName = appName,
            amount = amount,
            detail = buildDetail(),
            isIncome = false,
            keyword = keyword,
        )
    }

    /** 在「已选」页附近抽带 ¥ 的金额 */
    private fun extractAmountNearSelected(texts: List<String>, joined: String): Double? {
        // 先拼节点，处理「¥」「1.5」拆开的情况
        val normalized = texts.joinToString(" ") { it.trim() }.let { raw ->
            raw.replace(Regex("""[¥￥]\s*[|｜]\s*"""), "¥")
        }
        val sources = listOf(normalized, joined.replace(Regex("""[¥￥]\s*[|｜]\s*"""), "¥"))

        for (src in sources) {
            for (re in LABELED_AMOUNT.take(4)) {
                re.find(src)?.groupValues?.getOrNull(1)?.toDoubleOrNull()?.let { v ->
                    if (v > 0) return v
                }
            }
        }

        // 已选附近窗口
        val idx = joined.indexOf("已选")
        if (idx >= 0) {
            val window = joined.substring(
                (idx - 80).coerceAtLeast(0),
                (idx + 160).coerceAtMost(joined.length),
            ).replace(Regex("""[¥￥]\s*[|｜]\s*"""), "¥")
            YUAN_AMOUNT.findAll(window)
                .mapNotNull { it.groupValues[1].toDoubleOrNull() }
                .filter { it > 0 }
                .minOrNull()
                ?.let { return it }
        }

        // 全文里取所有带 ¥ 的金额，优先较小的实付价（排除明显原价）
        val all = YUAN_AMOUNT.findAll(normalized)
            .mapNotNull { it.groupValues[1].toDoubleOrNull() }
            .filter { it > 0 && it <= 100_000 }
            .toList()
        if (all.isEmpty()) return null
        if (all.size == 1) return all.first()
        // 多个价格时取最小正价（常见：现价 ¥1.3 / 原价 ¥11.3）
        return all.minOrNull()
    }

    private fun extractSelected(texts: List<String>, joined: String): String? {
        for (t in texts) {
            val m = SELECTED_PREFIX.find(t.trim()) ?: continue
            val body = m.groupValues[1].trim()
            if (body.isNotEmpty()) return body.take(80)
        }
        val m = SELECTED_PREFIX.find(joined) ?: return null
        val body = m.groupValues[1].trim()
        if (body.isEmpty()) return null
        val cut = body.indexOfFirst { it == '|' || it == '\n' }.let { if (it > 0) it else body.length }
        return body.take(cut).trim().take(80).ifEmpty { null }
    }

    private fun extractProductTitle(texts: List<String>): String? {
        val candidates = texts.map { it.trim() }.filter { t ->
            t.length in 8..80 &&
                !t.startsWith("#") &&
                !t.contains("¥") &&
                !t.contains("￥") &&
                !t.contains("已拼") &&
                !t.matches(Regex("""^[\d./\s]+$""")) &&
                TITLE_NOISE.none { n -> t.contains(n) } &&
                t.count { it in '\u4e00'..'\u9fff' } >= 6
        }
        if (candidates.isEmpty()) return null

        val ranked = candidates
            .groupingBy { it }
            .eachCount()
            .entries
            .sortedWith(
                compareByDescending<Map.Entry<String, Int>> { it.value }
                    .thenByDescending { it.key.length },
            )

        return ranked.firstOrNull()?.key
    }

    private fun extractAmount(joined: String, keyword: String): Double? {
        val idx = joined.indexOf(keyword)
        if (idx >= 0) {
            val window = joined.substring(
                (idx - 40).coerceAtLeast(0),
                (idx + 120).coerceAtMost(joined.length),
            )
            for (re in LABELED_AMOUNT) {
                re.find(window)?.groupValues?.getOrNull(1)?.toDoubleOrNull()?.let { return it }
            }
        }

        for (re in LABELED_AMOUNT) {
            re.find(joined)?.groupValues?.getOrNull(1)?.toDoubleOrNull()?.let { return it }
        }

        return null
    }

    /** 备注：标题：xx\n规格：xx */
    private fun buildDetail(): String {
        val title = cachedProductTitle.orEmpty()
        val spec = cachedSelected.orEmpty()
        val remark = when {
            title.isNotBlank() && spec.isNotBlank() -> "标题：$title\n规格：$spec"
            title.isNotBlank() -> "标题：$title"
            spec.isNotBlank() -> "规格：$spec"
            else -> "拼多多 支付"
        }
        return remark.take(120)
    }
}
