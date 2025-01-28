import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/AdminPage/adminpage.dart';
import 'package:hoteldineflutter/pages/UserPage/home.dart';
import 'package:hoteldineflutter/pages/getStartedPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hoteldineflutter/pages/login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes debug banner
      home: const AuthWrapper(), // Dynamic landing page
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  final String adminEmail = "admin@gmail.com";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if Firebase has completed initialization
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check the authentication state of the user
        if (snapshot.hasData) {
          final user = snapshot.data!;

          if (!user.emailVerified) {
            // If the user's email is not verified, show login page
            return  login();
          }

          if (user.email == adminEmail) {
            // If the user is an admin, show the admin page
            return  adminPage();
          } else {
            // For regular users, show the homepage
            return  Homepage();
          }
        } else {
          // If no user is authenticated, show the get started page
          return  getStartedPage();
        }
      },
    );
  }
}
