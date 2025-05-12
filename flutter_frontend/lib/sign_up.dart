import 'package:flutter/material.dart';
import 'package:tapin/filter_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // App colors
  static const _uwPurple = Color(0xFF7D3CFF); // Background
  static const _beige = Color(0xFFF5D598); // Gradient start
  static const _white = Color(0xFFFFFFFF); // Text / icon
  static const _black = Color(0xFF000000); // Text / icon

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _uwPurple, // Set the background color
      appBar: AppBar(
        backgroundColor: _beige, // AppBar background color
        title: const Text(
          'Sign Up',
          style: TextStyle(color: _black), // AppBar title color
        ),
        iconTheme: const IconThemeData(color: _black), // AppBar icon color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // First Name Field
            CustomTextField(
              controller: _firstNameController,
              labelText: 'First Name',
              labelColor: _white, // Label color
              textColor: _white, // Input text color
              obscureText: false,
            ),
            const SizedBox(height: 16),
            // Last Name Field
            CustomTextField(
              controller: _lastNameController,
              labelText: 'Last Name',
              labelColor: _white,
              textColor: _white,
              obscureText: false,
            ),
            const SizedBox(height: 16),
            // Email Field
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              labelColor: _white,
              textColor: _white,
              obscureText: false,
            ),
            const SizedBox(height: 16),
            // Phone Number Field
            CustomTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              labelColor: _white,
              textColor: _white,
              obscureText: false,
            ),
            const SizedBox(height: 16),
            // Password Field
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              labelColor: _white,
              textColor: _white,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Confirm Password Field
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              labelColor: _white,
              textColor: _white,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Sign Up Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _beige, // Button background color
                foregroundColor: _black, // Button text color
              ),
              onPressed: _isLoading ? null : _signUp,
              child:
                  _isLoading
                      ? const CircularProgressIndicator(
                        color: _black,
                      ) // Loading spinner color
                      : const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  void _signUp() {
    setState(() {
      _isLoading = true;
    });

    // Simulate a network request
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Navigate to the Explore screen after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FilterScreen()),
      );
    });
  }
}

// Custom widget for text input fields
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Color labelColor;
  final Color textColor;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.labelColor,
    required this.textColor,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: textColor), // Input text color
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: labelColor), // Label text color
        border: const OutlineInputBorder(),
      ),
    );
  }
}
