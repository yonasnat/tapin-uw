import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapin/profile_screen.dart';

void main() {
  testWidgets('Profile screen shows basic elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    // Verify basic UI elements are present
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('@johndoe'), findsOneWidget);
    expect(find.text('Uploaded Photos'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
