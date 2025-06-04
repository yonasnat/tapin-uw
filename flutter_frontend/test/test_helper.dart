import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupFirebaseForTesting() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with test configuration
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'test-api-key',
      appId: 'test-app-id',
      messagingSenderId: 'test-sender-id',
      projectId: 'test-project-id',
    ),
  );
}

// Helper widget to wrap test widgets with necessary providers
class TestWrapper extends StatelessWidget {
  final Widget child;

  const TestWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: child,
    );
  }
} 