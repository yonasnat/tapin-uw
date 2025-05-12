import 'package:flutter/material.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});
  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Matchmaking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Color(0xFFF8EFD9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Photo Here
                // Container(
                //   height: 300,
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(12.0),
                //   ),
                // ),
                // Image.asset('assets/images/blank_profile_picture.png', width: 300, height: 300),
                SizedBox(height: 15),
                // User First Name, Last Name
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                // User Bio
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Hi! I am a student at the University of Washington studying computer science. I enjoy hanging out with my friends and meeting new people!', style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 5),
                // Interests List
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pull list of interests from backend
                      Text('- Programming', style: TextStyle(fontSize: 16)),
                      Text('- Hiking', style: TextStyle(fontSize: 16)),
                      Text('- Photography', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                Spacer(),
                // Ignore Button and Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      // Configure onPress to ignore user
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          side: BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Ignore'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      // Configure onPress to add user
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color(0xFFDDB676),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          side: BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Add'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
