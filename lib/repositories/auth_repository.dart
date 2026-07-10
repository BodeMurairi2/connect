import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    // this function handles login with email and password
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    // this function handles user registering
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> saveUserToFirestore({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String role,
  }) async {
    await _firestore.collection('Users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser!.sendEmailVerification();
  }

  Future<void> signOut() async => await _auth.signOut();
}
