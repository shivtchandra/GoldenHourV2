import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:film_cam/main.dart';

void main() {
  testWidgets('GoldenHour app launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GoldenHourApp()));
    
    // Verify title is shown
    expect(find.text('GOLDENHOUR'), findsOneWidget);
  });
}
