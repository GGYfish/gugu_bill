package com.guguyu.gugu_bill.parser

/**
 * 按 App 适配的支付页解析器。
 * 一个一个加：先拼多多，其它后续再补。
 */
interface PaymentAppParser {
    val packageName: String
    val appName: String

    /**
     * 每次扫到页面都调用：可在商品详情页缓存标题等上下文，
     * 供支付成功时写入备注。
     */
    fun observePage(texts: List<String>, joined: String) {}

    /** 是否像支付成功相关页（用于决定要不要深扫 / 打全文日志） */
    fun looksLikeSuccessPage(texts: List<String>, joined: String): Boolean

    /** 解析；非成功页返回 null */
    fun parse(texts: List<String>, joined: String, className: String): PaymentParseResult?
}
