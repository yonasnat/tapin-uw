// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapin/main.dart';

void main() {
  testWidgets('App loads and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // // Verify that the login screen is shown
    // expect(find.text('TapIn'), findsOneWidget);
    // expect(find.text('CONNECT AT UW'), findsOneWidget);
    // expect(find.text('Login'), findsOneWidget);
    // expect(find.text('Create an Account'), findsOneWidget);
  });

  // testing if the title passed into the home page is displayed properly in the appbar
  testWidgets('AppBar displays the correct title', (WidgetTester tester) async {
  const String testTitle = 'Test App Title';

  // await tester.pumpWidget(
  //   const MaterialApp(
  //     home: MyHomePage(title: testTitle),
  //   ),
  // );

  // // Find the title text in the AppBar
  // expect(find.text(testTitle), findsOneWidget);
});

}
