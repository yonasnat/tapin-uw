import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapin/profile_form.dart'; 

void main() {
  testWidgets('Profile form shows major and interests fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ProfileForm(), 
      ),
    ));

    // Verify key form fields exist
    expect(find.text('Major'), findsOneWidget);
    expect(find.text('Interests'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Computer Science');
    expect(find.text('Computer Science'), findsOneWidget);
  });
}
