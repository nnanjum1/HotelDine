import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hoteldineflutter/pages/login.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext contet) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),  // Firebase Auth state change stream
        builder: (context, snapshot) {
          // Handle different states
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show a loading indicator while waiting
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
          } else if (snapshot.hasData && snapshot.data != null) {
            // User is logged in
            return Center(child: Text('User is logged in!'));
          } else {
            // No user, show login screen
            return login();
          }
        },
      ),
    );
  }
}
