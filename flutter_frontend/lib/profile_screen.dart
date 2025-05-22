import 'package:flutter/material.dart';
import 'package:tapin/login.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // App colors (same as in sign_up.dart)
  static const _uwPurple = Color(0xFF7D3CFF); // Background
  static const _beige = Color(0xFFF5D598); // Gradient start
  static const _white = Color(0xFFFFFFFF); // Text / icon
  static const _black = Color(0xFF000000); // Text / icon

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _uwPurple, // Set the background color
      appBar: AppBar(
        backgroundColor: _beige, // AppBar background color
        // add logout button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle logout action
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                ); 
            },
          ),
        ],
        title: const Text(
          'Profile',
          style: TextStyle(color: _black), // AppBar title color
        ),
        iconTheme: const IconThemeData(color: _black), // AppBar icon color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  // Placeholder for profile picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: _beige,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: _black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Name and Username
                  const Text(
                    'Full Name', // Replace with dynamic name
                    style: TextStyle(
                      color: _white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '@username', // Replace with dynamic username
                    style: TextStyle(
                      color: _white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Photos Section Title
            const Text(
              'Uploaded Photos',
              style: TextStyle(
                color: _white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Grid of Uploaded Photos
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of photos per row
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12, // Replace with the actual number of photos
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: _beige,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: _black,
                      size: 40,
                    ), // Replace with actual photo widget
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
