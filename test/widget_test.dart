import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gugu_bill/theme/app_colors_data.dart';

void main() {
  testWidgets('AppColorsData 主题色数据可访问', (WidgetTester tester) async {
    // 验证内置主题存在
    expect(AppPresets.defaultBlue.primary, isA<Color>());
    expect(AppPresets.mintGreen.primary, isA<Color>());
    expect(AppPresets.cherryPink.primary, isA<Color>());
    expect(AppPresets.sunshineOrange.primary, isA<Color>());
    expect(AppPresets.nightBlack.primary, isA<Color>());
  });

  test('AppColorsData JSON 序列化往返一致', () {
    final original = AppPresets.defaultBlue;
    final json = original.toJson();
    final restored = AppColorsData.fromJson(json);
    expect(restored.id, original.id);
    expect(restored.name, original.name);
    expect(restored.primary, original.primary);
    expect(restored.isDark, original.isDark);
  });
}
