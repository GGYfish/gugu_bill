import 'package:decimal/decimal.dart';

/// All money in the app is represented as [Decimal] (unit: yuan).
/// - Parse: [parseMoney] / [decimalOf] / [asDecimal]
/// - Display: [formatMoney] (2 fraction digits)
/// - Chart / legacy double-only APIs: [asDouble]

/// Convert num (double/int) to Decimal without binary float error.
/// Uses the shortest round-trip string form so 2-decimal values restore exactly.
Decimal decimalOf(num value) => Decimal.parse(value.toString());

/// Parse a money string to Decimal, returns 0 on invalid input.
/// Tolerates a trailing dot like "12.", leading currency symbols ("¥ 500",
/// "￥500元", "1,234.56") by stripping non-numeric characters first.
Decimal parseMoney(String text) {
  var normalized = text.trim();
  if (normalized.isEmpty) return Decimal.zero;
  // 只保留数字、小数点、负号：去掉 ¥ ￥ $ 逗号（半角/全角）空格及"元/块/圆"等单位
  normalized = normalized.replaceAll(RegExp(r'[¥￥$,\s，]'), '');
  normalized = normalized.replaceAll(RegExp(r'[元块圆]'), '');
  if (normalized.isEmpty || normalized == '-' || normalized == '.') {
    return Decimal.zero;
  }
  if (normalized.endsWith('.')) {
    return Decimal.tryParse(normalized.substring(0, normalized.length - 1)) ??
        Decimal.zero;
  }
  return Decimal.tryParse(normalized) ?? Decimal.zero;
}

/// Accept Decimal / num / String / null and convert to Decimal.
/// Used at boundaries where the value type is dynamic (mock data, JSON, maps).
Decimal asDecimal(dynamic value) {
  if (value is Decimal) return value;
  if (value is num) return decimalOf(value);
  if (value is String) return parseMoney(value);
  return Decimal.zero;
}

/// Decimal to double, for chart libraries and other double-only APIs.
double asDouble(dynamic value) => asDecimal(value).toDouble();

/// Format Decimal as a 2-decimal string for display.
String formatMoney(Decimal value) => value.toStringAsFixed(2);

/// Round half away from zero to 2 decimals.
Decimal round2(Decimal value) => Decimal.parse(value.toStringAsFixed(2));

/// Exact division by an int, truncated to 2 decimals (for monthly installments).
/// A scale is required because results like 10000/3 have infinite precision.
Decimal divMoney(Decimal value, int divisor) =>
    (value / Decimal.fromInt(divisor)).toDecimal(scaleOnInfinitePrecision: 2);

/// Percentage (0-100) of [part] over [whole], rounded to 2 decimals.
/// Returns 0 when [whole] is 0.
Decimal percentOf(Decimal part, Decimal whole) {
  if (whole == Decimal.zero) return Decimal.zero;
  return round2((part * Decimal.fromInt(100) / whole).toDecimal(scaleOnInfinitePrecision: 4));
}
