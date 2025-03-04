import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required String address,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign In with email and password
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw e.toString();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Verify OTP code
  Future<void> verifyOTP(String email, String code) async {
    try {
      await _auth.verifyPasswordResetCode(code);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Invalid or expired code';
    }
  }

  // Reset password with new password
  Future<void> resetPassword(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Failed to reset password';
    }
  }

  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw e;
    }
  }

  bool isAdminEmail(String email) {
    return email.toLowerCase() == 'rajdummy31@gmail.com';
  }
}