import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiatia/utils/colors.dart';
import 'package:tiatia/main.dart';

void main() {
  testWidgets('Тестирование темы приложения', (WidgetTester tester) async {
    // Запускаем приложение
    await tester.pumpWidget(MyApp());

    // Проверяем, что шрифт приложения установлен корректно
    final titleFinder = find.text('TIA');
    final titleWidget = titleFinder.evaluate().first.widget as Text;
    expect(titleWidget.style?.fontFamily, 'Bitter');

    // Проверяем, что цвета приложения установлены корректно
    final primaryColor = Theme.of(tester.element(titleFinder)).primaryColor;
    expect(primaryColor, AppColors.primary);

    // Проверяем, что освещение приложения установлено корректно
    final brightness = Theme.of(tester.element(titleFinder)).brightness;
    expect(brightness, Brightness.light);
  });
}