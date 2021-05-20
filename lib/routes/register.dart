import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xlo_auction_app/authentication/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xlo_auction_app/model/route_generator.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var error = '';
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Register',
              textScaleFactor: 2,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: TextField(
                key: Key('emailTextField'),
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'email',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.only(left: 5),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'password',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.only(left: 5),
                ),
                obscureText: true,
              ),
            ),
            Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            ElevatedButton(
              onPressed: () => _createUserWithEmail(context),
              child: const Text('Register'),
            ),
            RichText(
              text: TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Sign in',
                    style: TextStyle(
                      color: Colors.lightBlue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.of(context)
                          ?.pushNamed(RouteGenerator.signInPage),
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
      setState(() {
        error = e.message;
      });

      // showAuthenticationNotification(
      //   context,
      //   'Error',
      //   e.message,
      // );
    }
  }
}
