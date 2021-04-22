import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xlo_auction_app/authentication/authentication.dart';
import 'package:xlo_auction_app/authentication/authenticationNotification.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
              'Register',
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
              onPressed: () => _createUserWithEmail(context),
              child: const Text('Register'),
            ),
            RichText(
              text: TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(
                  color: CupertinoColors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Sign in',
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.pushNamed(
                            context,
                            '/signIn',
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createUserWithEmail(BuildContext context) async {
    try {
      await context.read<AuthenticationService>().createUserWithEmail(
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
  }
}
