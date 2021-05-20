import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:xlo_auction_app/authentication/authentication.dart';
import 'package:provider/provider.dart';
import 'package:xlo_auction_app/routes/register.dart';
import 'package:xlo_auction_app/routes/signIn.dart';
import 'package:xlo_auction_app/routes/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseFirestore>(
          create: (_) => FirebaseFirestore.instance,
        ),
        Provider<FirebaseStorage>(
          create: (_) => FirebaseStorage.instance,
        ),
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          // brightness: Brightness.dark,
          primarySwatch: Colors.deepPurple,
          accentColor: Colors.cyan[200],
          brightness: Brightness.light,
        ),
        title: 'todo library',
        initialRoute: '/',
        routes: {
          '/': (context) => AuthenticationWrapper(),
          '/signIn': (context) => SignIn(),
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return HomePage();
    }
    return Register();
  }
}
