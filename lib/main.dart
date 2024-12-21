import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hoteldineflutter/pages/AdminPage/adminpage.dart';
import 'package:hoteldineflutter/pages/UserPage/home.dart';
import 'package:hoteldineflutter/pages/getStartedPage.dart';

import 'package:firebase_core/firebase_core.dart';
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

  final String adminEmail = "admin@gmail.com";

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    Widget _getHomePage() {
      if (user != null) {
        if (user.email == adminEmail) {
          return const adminPage();
        } else {
          // Navigate to the home page for regular users
          return const Homepage();
        }
      } else {
        // Navigate to the get started page for unauthenticated users
        return  getStartedPage();
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes debug banner
      home: _getHomePage(), // Determine the landing page
    );
  }
}
