import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xlo_auction_app/authentication/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xlo_auction_app/model/route_generator.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
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
              'Login',
              textScaleFactor: 2,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: TextField(
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
      setState(() {
        error = e.message;
      });
      // showAuthenticationNotification(
      //   context,
      //   'Error',
      //   e.message,
      // );
    }
    if (isSignedIn == true) {
      Navigator.of(context)?.popAndPushNamed(RouteGenerator.homePage);
      // Navigator.popAndPushNamed(context, '/');
      // if (!authentication.isEmailVerified) {
      //   showAuthenticationNotification(context, 'Verify email', 'Verify email');
      // }
    }
  }
}
