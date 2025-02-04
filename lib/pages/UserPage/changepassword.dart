import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  bool isCurrentPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  String? errorMessage;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updatePassword() async {
    String currentPassword = currentPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmNewPassword = confirmNewPasswordController.text;

    User? user = _auth.currentUser;

    if (user == null) {
      Fluttertoast.showToast(msg: 'User not logged in.');
      return;
    }

    if (newPassword != confirmNewPassword) {
      setState(() {
        errorMessage = "New passwords do not match";
      });
      return;
    }

    try {
      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      setState(() {
        errorMessage = null;
      });

      Fluttertoast.showToast(msg: 'Password updated successfully.');
      Navigator.pop(context); // Navigate back after success

    } catch (e) {
      setState(() {
        errorMessage = "Current password do not match";
        print("Error: ${e.toString()}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current Password Field
            TextField(
              controller: currentPasswordController,
              obscureText: !isCurrentPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Current Password',
                hintStyle: TextStyle(color: Colors.grey,),
                filled: true,
                fillColor: const Color(0xFFDCDCDC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(isCurrentPasswordVisible ? Icons.visibility_off : Icons.visibility),
                  color: Colors.grey,
                  onPressed: () {
                    setState(() {
                      isCurrentPasswordVisible = !isCurrentPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // New Password Field
            TextField(
              controller: newPasswordController,
              obscureText: !isNewPasswordVisible,
              decoration: InputDecoration(
                hintText: 'New Password',
                hintStyle: TextStyle(color: Colors.grey,),
                filled: true,
                fillColor: const Color(0xFFDCDCDC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(isNewPasswordVisible ? Icons.visibility_off : Icons.visibility),
                  color: Colors.grey,
                  onPressed: () {
                    setState(() {
                      isNewPasswordVisible = !isNewPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Confirm New Password Field
            TextField(
              controller: confirmNewPasswordController,
              obscureText: !isConfirmPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Confirm New Password',
                hintStyle: TextStyle(color: Colors.grey,),
                filled: true,
                fillColor: const Color(0xFFDCDCDC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                  color: Colors.grey,
                  onPressed: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Display error message if any
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),

            // Update Password Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF19A7FE),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: updatePassword,
              child: const Text(
                'Update Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
