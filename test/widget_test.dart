import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:monopoli_indonesia/constants/app_constants.dart';

void main() {
  testWidgets('App constants are defined', (WidgetTester tester) async {
    expect(AppStrings.appName, 'Monopoli Indonesia');
    expect(AppColors.primary, isA<Color>());
    expect(AppColors.accent, isA<Color>());
  });
}
