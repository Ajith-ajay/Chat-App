import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in with Email and Password
  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Store or update user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'signInMethod': 'email',
      }, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  /// Sign up with Email and Password
  Future<UserCredential> signUpWithEmailandPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'signInMethod': 'email',
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  /// Sign in or register with Phone Number (OTP-based)
  // Future<void> verifyPhoneNumber({
  //   required String phoneNumber,
  //   required Function(String verificationId) codeSent,
  //   required Function(PhoneAuthCredential credential) onAutoVerified,
  //   required Function(String error) onError,
  //   required Function(String verificationId) onTimeout,
  // }) async {
  //   await _firebaseAuth.verifyPhoneNumber(
  //     phoneNumber: phoneNumber,
  //     timeout: Duration(seconds: 60),
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       await _firebaseAuth.signInWithCredential(credential);
  //       onAutoVerified(credential);
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       onError(e.message ?? "Phone verification failed");
  //     },
  //     codeSent: (String verificationId, int? resendToken) {
  //       codeSent(verificationId);
  //     },
  //     codeAutoRetrievalTimeout: (String verificationId) {
  //       onTimeout(verificationId);
  //     },
  //   );
  // }

  // Start phone auth and return verificationId
  Future<String> verifyPhoneNumber(
      String phone, Function(String) onCodeSent) async {
    Completer<String> completer = Completer();
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e.message ?? "Verification failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return completer.future;
  }

  // Confirm OTP
  Future<void> signInWithOTP(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    await _firebaseAuth.signInWithCredential(credential);
  }

  /// Sign in with OTP
  // Future<UserCredential> signInWithOTP({
  //   required String verificationId,
  //   required String smsCode,
  // }) async {
  //   try {
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId,
  //       smsCode: smsCode,
  //     );

  //     UserCredential userCredential =
  //         await _firebaseAuth.signInWithCredential(credential);

  //     // Save to Firestore
  //     await _firestore.collection('users').doc(userCredential.user!.uid).set({
  //       'uid': userCredential.user!.uid,
  //       'phone': userCredential.user!.phoneNumber,
  //       'signInMethod': 'phone',
  //     }, SetOptions(merge: true));

  //     return userCredential;
  //   } on FirebaseAuthException catch (e) {
  //     throw Exception(e.message ?? "OTP verification failed");
  //   }
  // }

  Future<void> saveUserDetailsToFirestore({
    required String username,
    required String email,
    required String phone,
    required String dob,
  }) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'username': username,
      'email': email,
      'phone': phone,
      'dob': dob,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Sign out
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;
}
