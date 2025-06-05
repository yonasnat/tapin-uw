import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapin/filter_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Fake FirebaseAuth
class FakeAuth implements FirebaseAuth {
  @override
  User? get currentUser => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// Fake FirebaseFirestore
class FakeFirestore implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    throw UnimplementedError();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  testWidgets('FilterScreen has correct title', (WidgetTester tester) async {
    // Use the fake auth and firestore
    final fakeAuth = FakeAuth();
    final fakeFirestore = FakeFirestore();

    await tester.pumpWidget(MaterialApp(
      home: FilterScreen(auth: fakeAuth, firestore: fakeFirestore),
    ));

    // Find the AppBar and verify its title
    final appBarFinder = find.byType(AppBar);
    expect(appBarFinder, findsOneWidget);
    
    final appBar = tester.widget<AppBar>(appBarFinder);
    expect(appBar.title, isA<Text>());
    expect((appBar.title as Text).data, 'Filter');
  });
} 