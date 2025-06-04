import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapin/filter_screen.dart';

void main() {
  testWidgets('FilterScreen has correct title', (WidgetTester tester) async {
    // Build our widget
    await tester.pumpWidget(const MaterialApp(home: FilterScreen()));

    // Find the AppBar and verify its title
    final appBarFinder = find.byType(AppBar);
    expect(appBarFinder, findsOneWidget);
    
    final appBar = tester.widget<AppBar>(appBarFinder);
    expect(appBar.title, isA<Text>());
    expect((appBar.title as Text).data, 'Filter');
  });
} 