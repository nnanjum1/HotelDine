import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hoteldineflutter/pages/AdminPage/adminpage.dart';
import 'package:hoteldineflutter/pages/UserPage/home.dart';
import 'package:hoteldineflutter/pages/getStartedPage.dart';
import 'package:hoteldineflutter/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

// 🔹 AuthWrapper to check Firebase authentication state
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<Widget> _homePage;

  @override
  void initState() {
    super.initState();
    _homePage = checkLoginStatus(); // Initialize login check
  }

  Future<Widget> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? role = prefs.getString('role');

    // Debugging: Print stored values
    print("isLoggedIn: $isLoggedIn");
    print("role: $role");

    if (isLoggedIn && role != null) {
      if (role == "admin") {
        return const adminPage();
      } else {
        return const Homepage();
      }
    } else {
      return  getStartedPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _homePage, // Get home page based on login status
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        }

        return  getStartedPage();
      },
    );
  }
}
