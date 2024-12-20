import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final fullNameControl = TextEditingController();
    final userEmail = TextEditingController();
    final phoneNumber = TextEditingController();
    final dobController = TextEditingController();
    final userPassword = TextEditingController();
    final confirmPassword = TextEditingController();

    // Sign-up function
    void signUp() async {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: userEmail.text,
          password: userPassword.text,
        );

        if (credential.user != null) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred.')),
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
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Full Name
                  TextFormField(
                    controller: fullNameControl,
                    decoration: customInputDecoration('Full name', Icons.person),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your full name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: userEmail,
                    decoration: customInputDecoration('Email address', Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value ?? '')
                        ? 'Please enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  TextFormField(
                    controller: phoneNumber,
                    decoration: customInputDecoration('Phone number', Icons.phone),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                    !RegExp(r'^\d{11}$').hasMatch(value ?? '')
                        ? 'Please enter a valid 11-digit phone number'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Date of Birth
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
                    validator: (value) =>
                    value!.isEmpty ? 'Please select your date of birth' : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: userPassword,
                    decoration: customInputDecoration('Password', Icons.lock),
                    obscureText: true,
                    validator: (value) =>
                    (value ?? '').length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: confirmPassword,
                    decoration: customInputDecoration('Confirm password', Icons.lock),
                    obscureText: true,
                    validator: (value) =>
                    value != userPassword.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
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

                  // Login Prompt
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
                              fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
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
