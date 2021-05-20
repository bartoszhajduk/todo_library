import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationService {
  final FirebaseAuth _authenticator = FirebaseAuth.instance;

  // singleton
  static final AuthenticationService _authenticationService =
      AuthenticationService._internal();
  factory AuthenticationService() => _authenticationService;

  AuthenticationService._internal();

  Stream<User> get authStateChanges => _authenticator.authStateChanges();
  bool get isEmailVerified => _authenticator.currentUser.emailVerified;

  Future<void> createUserWithEmail(
      BuildContext context, String email, String password) async {
    await _authenticator.createUserWithEmailAndPassword(
        email: email, password: password);

    if (!_authenticator.currentUser.emailVerified) {
      _authenticator.currentUser.sendEmailVerification();
      // showAuthenticationNotification(
      //     context, 'Verify email', 'Verification link sent to email');
    }
  }

  Future<bool> signInWithEmail(
      BuildContext context, String email, String password) async {
    var isSignedIn = false;

    await _authenticator.signInWithEmailAndPassword(
        email: email, password: password);

    if (_authenticator.currentUser != null) {
      isSignedIn = true;
    }

    return isSignedIn;
  }

  Future<void> signOut() async {
    await _authenticator.signOut();
  }

  String getCurrentUserId() {
    return _authenticator.currentUser.uid;
  }

  String getCurrentUserEmail() {
    return _authenticator.currentUser.email;
  }

  Future<void> logout() async {
    await _authenticator.signOut();
  }
}
