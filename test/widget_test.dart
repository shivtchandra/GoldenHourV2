import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:film_cam/main.dart';

void main() {
  testWidgets('FilmCam app launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FilmCamApp()));
    
    // Verify FILMCAM title is shown
    expect(find.text('FILMCAM'), findsOneWidget);
  });
}
