import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Database/database.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final fullNameControl = TextEditingController();
  final userEmail = TextEditingController();
  final phoneNumber = TextEditingController();
  final dobController = TextEditingController();
  final userPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Sign-up function
  void signUp() async {
    try {
      // Firebase Authentication signup

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userEmail.text,
        password: userPassword.text,
      );

      if (credential.user != null) {
        // Appwrite: Insert user details into the "Users" collection
        final userCollection = databaseService.getCollection('Users');
        await userCollection['create'](
          payload: {
            'fullName': fullNameControl.text,
            'email': userEmail.text,
            'phone': phoneNumber.text,
            'dob': dobController.text,
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const login()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.code == 'weak-password'
          ? 'The password provided is too weak.'
          : e.code == 'email-already-in-use'
          ? 'The account already exists for that email.'
          : e.message ?? 'An error occurred';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Log the error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const login()),
      );
    }


  }

  InputDecoration customInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[200],
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Text(
              'Create your account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create your personal account now to access all the exclusive benefits we have to offer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: fullNameControl,
                    decoration: customInputDecoration('Full name', Icons.person),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your full name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: userEmail,
                    decoration: customInputDecoration('Email address', Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value ?? '')
                        ? 'Please enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneNumber,
                    decoration: customInputDecoration('Phone number', Icons.phone),
                    keyboardType: TextInputType.phone,
                    validator: (value) => !RegExp(r'^\d{11}$')
                        .hasMatch(value ?? '')
                        ? 'Please enter a valid 11-digit phone number'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dobController,
                    decoration: customInputDecoration(
                        'Date of birth eg.(yyyy-mm-dd)', Icons.calendar_today),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        dobController.text =
                        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      }
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please select your date of birth';
                      }
                      final dob = DateTime.tryParse(value);
                      if (dob == null) {
                        return 'Invalid date format';
                      }
                      final currentDate = DateTime.now();
                      final age = currentDate.year -
                          dob.year -
                          (currentDate.isBefore(
                              DateTime(currentDate.year, dob.month, dob.day))
                              ? 1
                              : 0);
                      if (age < 18) {
                        return 'You must be at least 18 years old';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: userPassword,
                    decoration: customInputDecoration('Password', Icons.lock)
                        .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) => (value ?? '').length < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPassword,
                    decoration:
                    customInputDecoration('Confirm password', Icons.lock)
                        .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => value != userPassword.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          signUp();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(fontSize: 16)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const login()),
                          );
                        },
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
