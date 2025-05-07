import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapin/main.dart';

void main() {
  testWidgets('MyApp renders home screen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Verify basic UI elements are present
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
