import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tapin/filter_screen.dart';
import 'package:tapin/login.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // app colors 
  static const _uwPurple = Color(0xFF7D3CFF);
  static const _beige = Color(0xFFF5D598);
  static const _white = Color(0xFFFFFFFF);
  static const _black = Color(0xFF000000);

  // Text controllers for each input field 
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false; // Tracks if signup is in progress
  String? _errorMessage; // Stores any error messages to display

  // Field validation flags 
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isPasswordMatch = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _uwPurple,
      appBar: AppBar(
        backgroundColor: _beige,
        title: const Text('Sign Up', style: TextStyle(color: _black)),
        iconTheme: const IconThemeData(color: _black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //  Input fields for user info 
            CustomTextField(controller: _firstNameController, labelText: 'First Name', labelColor: _white, textColor: _white, obscureText: false, errorText: null),
            const SizedBox(height: 16),
            CustomTextField(controller: _lastNameController, labelText: 'Last Name', labelColor: _white, textColor: _white, obscureText: false, errorText: null),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              labelColor: _white,
              textColor: _white,
              obscureText: false,
              errorText: !_isEmailValid ? 'Please enter a valid @uw.edu email' : null,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(controller: _phoneController, labelText: 'Phone Number', labelColor: _white, textColor: _white, obscureText: false, errorText: null, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              labelColor: _white,
              textColor: _white,
              obscureText: true,
              errorText: !_isPasswordValid ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              labelColor: _white,
              textColor: _white,
              obscureText: true,
              errorText: !_isPasswordMatch ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 16),

            //  Display error messages if validation or signup fails 
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            //  Sign Up Button 
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _beige,
                foregroundColor: _black,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _isLoading ? null : _signUp,
              child: _isLoading
                  ? const CircularProgressIndicator(color: _black)
                  : const Text('Sign Up'),
            ),

            const SizedBox(height: 16),

            // Link to Login screen 
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Already have an account? Login',
                style: TextStyle(color: _white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Validates user input before attempting signup 
  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _isEmailValid = email.isNotEmpty && email.endsWith('@uw.edu');
      _isPasswordValid = password.length >= 6;
      _isPasswordMatch = password == confirmPassword;
    });

    return _isEmailValid && _isPasswordValid && _isPasswordMatch;
  }

  // Handles signup logic with Firebase Cloud Functions
  Future<void> _signUp() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare the request body
      final requestBody = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'displayName': '${_firstNameController.text} ${_lastNameController.text}',
        'bio': '',
        'interests': [],
      };

      // Make HTTP request to the cloud function
      final response = await http.post(
        Uri.parse('https://createuser-ybcbaxrbca-uc.a.run.app'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        // Parse the response
        final responseData = jsonDecode(response.body);
        
        if (responseData['token'] != null) {
          // Sign in with the custom token if available
          await FirebaseAuth.instance.signInWithCustomToken(responseData['token']);
        } else {
          // If no token, sign in with email/password
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
        }

        // Navigate to filter screen after success
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FilterScreen(
            auth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
          )),
        );
      } else {
        // Handle error response
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorData['message'] ?? 'Signup failed. Please try again.';
        });
      }
    } catch (e) {
      print("Signup error: $e");
      setState(() {
        _errorMessage = 'An error occurred during signup. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

//  Custom input field widget with built in error handling 
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Color labelColor;
  final Color textColor;
  final bool obscureText;
  final String? errorText;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.labelColor,
    required this.textColor,
    required this.obscureText,
    this.errorText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType ?? TextInputType.text,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: labelColor),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
