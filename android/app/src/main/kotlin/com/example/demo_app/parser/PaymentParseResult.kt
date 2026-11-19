package com.guguyu.gugu_bill.parser

/**
 * 单个 App 解析出的支付结果。
 */
data class PaymentParseResult(
    val appName: String,
    val amount: Double,
    val detail: String,
    val isIncome: Boolean = false,
    val keyword: String,
)
