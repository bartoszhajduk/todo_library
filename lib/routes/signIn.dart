import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xlo_auction_app/authentication/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xlo_auction_app/authentication/authenticationNotification.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login',
              textScaleFactor: 2,
            ),
            CupertinoTextField(
              controller: emailController,
              placeholder: 'email',
            ),
            CupertinoTextField(
              controller: passwordController,
              placeholder: 'password',
              obscureText: true,
            ),
            CupertinoButton(
              onPressed: () => _signInWithEmail(context),
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }

  void _signInWithEmail(BuildContext context) async {
    bool isSignedIn;
    final authentication = context.read<AuthenticationService>();

    try {
      isSignedIn = await authentication.signInWithEmail(
        context,
        emailController.text,
        passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      showAuthenticationNotification(
        context,
        'Error',
        e.message,
      );
    }
    if (isSignedIn == true) {
      Navigator.pop(context);
      Navigator.popAndPushNamed(context, '/');
      if (!authentication.isEmailVerified) {
        showAuthenticationNotification(context, 'Verify email', 'Verify email');
      }
    }
  }
}
