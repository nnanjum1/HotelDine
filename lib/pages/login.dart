import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hoteldineflutter/pages/AdminPage/adminpage.dart';
import 'package:hoteldineflutter/pages/UserPage/home.dart';
import 'package:hoteldineflutter/pages/signup.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<login> {
  bool isPasswordVisible = false;
  bool isRememberMeChecked = false;
  final TextEditingController emailAddress = TextEditingController();
  final TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final String adminEmail = "admin@gmail.com";
  final String adminPassword = "password";

  String errorMessage = '';

  // 🔹 Save login session in SharedPreferences
  Future<void> _saveLoginSession(String email, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    await prefs.setBool('isLoggedIn', true);
  }

  // 🔹 User login function
  void loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      errorMessage = ''; // Clear previous errors
    });

    try {
      if (emailAddress.text == adminEmail && password.text == adminPassword) {
        // ✅ **Admin Login**
        await _saveLoginSession(adminEmail, 'admin');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const adminPage()),
        );
      } else {
        // ✅ **User Login with Firebase**
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddress.text.trim(),
          password: password.text.trim(),
        );

        final user = userCredential.user;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          setState(() {
            errorMessage = 'Please verify your email and try again.';
          });
          await FirebaseAuth.instance.signOut();
          return;
        }

        // ✅ **Save session in SharedPreferences**
        await _saveLoginSession(user!.email!, 'user');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.code == 'user-not-found'
            ? 'No user found for that email.'
            : 'Incorrect email or password. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              top: 38,
              left: 8,
              right: 8,
              child: Image.asset(
                "assets/images/login.png",
                alignment: Alignment.topCenter,
                width: 360,
                height: 360,
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 400),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Welcome to HotelDine',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email TextFormField
                        TextFormField(
                          controller: emailAddress,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email address',
                            filled: true,
                            fillColor: const Color(0xFFDCDCDC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Password TextFormField
                        TextFormField(
                          controller: password,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'password',
                            filled: true,
                            fillColor: const Color(0xFFDCDCDC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),

                        // Error message display
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Remember Me and Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isRememberMeChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isRememberMeChecked = value!;
                                    });
                                  },
                                ),
                                const Text('Remember Me'),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                // Handle Forgot Password
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Login Button
                        ElevatedButton(
                          onPressed: loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF19A7FE),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Signup()),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}