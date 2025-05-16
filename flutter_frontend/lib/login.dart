import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tapin/sign_up.dart';
import 'package:tapin/filter_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Custom brand colors for the UI
  static const _uwPurple = Color(0xFF7D3CFF);
  static const _beigeFrom = Color(0xFFF5D598);
  static const _beigeTo = Color(0xFFE9C983);
  static const _navy = Color(0xFF231942);

  @override
  Widget build(BuildContext context) {
    // Controllers to retrieve text input from email and password fields
    final userCtl = TextEditingController();
    final passCtl = TextEditingController();

    return Scaffold(
      backgroundColor: _uwPurple,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TapIn Logo Section 
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_beigeFrom, _beigeTo],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.touch_app, size: 80, color: _navy),
                        SizedBox(height: 12),
                        Text('TapIn',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                            )),
                        Text('CONNECT AT UW',
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 1.4,
                              color: _navy,
                            )),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Email Input
                _LabeledField(controller: userCtl, hint: 'UW Email'),

                const SizedBox(height: 24),

                // Password Input 
                _LabeledField(controller: passCtl, hint: 'Password', obscure: true),

                const SizedBox(height: 36),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final email = userCtl.text.trim();
                      final password = passCtl.text;

                      // Validate user input before attempting login
                      if (email.isEmpty || password.isEmpty) {
                        _showErrorDialog(context, 'Please enter both email and password.');
                        return;
                      }

                      // Attempt Firebase login
                      _loginUser(context, email, password);
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18, color: _uwPurple),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Link to Sign Up 
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _beigeFrom,
                      side: const BorderSide(color: Colors.black54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to Sign Up page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      'Create an Account',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Handles the Firebase login logic
  void _loginUser(BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigate to Profile screen 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FilterScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Show a helpful error message based on Firebase's response
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with that email. Try signing up.';
          break;
        case 'wrong-password':
          message = 'Wrong password. Please try again.';
          break;
        case 'invalid-email':
          message = 'That email address is invalid.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = 'Login failed. Please try again later.';
      }
      _showErrorDialog(context, message);
    } catch (_) {
      // Fallback for any unknown errors
      _showErrorDialog(context, 'Something went wrong. Please try again.');
    }
  }

  // Helper method to show an error dialog box
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Reusable text field widget with optional password hiding
class _LabeledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const _LabeledField({
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
