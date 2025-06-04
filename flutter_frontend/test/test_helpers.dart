import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@GenerateMocks([FirebaseAuth, User, FirebaseFirestore, DocumentSnapshot], customMocks: [
  MockSpec<FirebaseAuth>(as: #MockFirebaseAuthBase),
  MockSpec<User>(as: #MockUserBase),
  MockSpec<FirebaseFirestore>(as: #MockFirebaseFirestoreBase),
  MockSpec<DocumentSnapshot>(as: #MockDocumentSnapshotBase),
])
void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
} 