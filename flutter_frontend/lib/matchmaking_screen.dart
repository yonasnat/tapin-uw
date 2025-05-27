import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});
  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  List<Map<String, dynamic>> _potentialMatches = [];
  int _currentMatchIndex = 0;
  bool _isLoading = true;
  bool _hasMoreMatches = true;
  bool _showSentRequests = false;

  // Premade profiles when there are no other users active
  final List<Map<String, dynamic>> _premadeProfiles = [
    {
      'firstName': 'Jason',
      'lastName': 'Smith',
      'bio': 'Hi I am Jason! I study computer science at UW and outside of school, I love hiking and photography. Looking to build connections and find outdoor adventure partners!',
      'interests': ['Programming', 'Hiking', 'Photography'],
      'photoURL': null,
    },
    {
      'firstName': 'Amy',
      'lastName': 'Lee',
      'bio': 'Hey my name is Amy! I am a business student passionate about entrepreneurship and basketball. Always down for a game or startup discussion!',
      'interests': ['Basketball', 'Business Major'],
      'photoURL': null,
    },
    {
      'firstName': 'Daniel',
      'lastName': 'Rodriguez',
      'bio': 'Hi everyone I am Daniel. I am an art major who enjoys painting and rock climbing. Looking for creative friends to explore Seattle with!',
      'interests': ['Art', 'Rock Climbing', 'Travel'],
      'photoURL': null,
    },
    {
      'firstName': 'David',
      'lastName': 'Kim',
      'bio': 'Engineering student who loves gaming and coding. Looking to meet people with similar interests!',
      'interests': ['Engineering', 'Coding', 'Robotics', 'Esports'],
      'photoURL': null,
    },
    {
      'firstName': 'Sophia',
      'lastName': 'Johnson',
      'bio': 'Hi I am a computer science major at UW. I like coding and playing video games, always trying to meet new people!',
      'interests': ['Computer Science', 'Gamer', 'Reading'],
      'photoURL': null,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _loadPotentialMatches();
  }

  Future<void> _loadPotentialMatches() async {
    try {
      setState(() => _isLoading = true);
      final result = await _functions.httpsCallable('getPotentialMatches').call();
      final data = result.data as Map<String, dynamic>;
      
      // Obtain data from Firebase regarding matches (if no data exists, use preloaded data)
      setState(() {
        _potentialMatches = List<Map<String, dynamic>>.from(data['matches'] ?? []);
        if (_potentialMatches.isEmpty) {
          _potentialMatches = List.from(_premadeProfiles);
        }
        _hasMoreMatches = data['hasMore'] as bool? ?? false;
        _currentMatchIndex = 0; // Reset index when loading new matches
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _potentialMatches = List.from(_premadeProfiles);
        _currentMatchIndex = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading matches: $e')),
      );
    }
  }

  Future<void> _handleIgnore() async {
    if (_potentialMatches.isEmpty || _currentMatchIndex >= _potentialMatches.length) {
      return;
    }
    final currentMatch = _potentialMatches[_currentMatchIndex];
    
    try {
      // Since there are preloaded profiles, only make Firebase calls on real profiles
      // Make a call indicating that current user has chose to ignore another user
      if (currentMatch['uid'] != null) {
        await _functions.httpsCallable('ignoreUser').call({
        'ignoredUid': currentMatch['uid'],
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Potential Match Ignored')));
      }

      setState(() {
        _currentMatchIndex++;
        if (_currentMatchIndex >= _potentialMatches.length && _hasMoreMatches) {
          _loadPotentialMatches();
        }
      });
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ignoring user: $e')),
      );
    }
  }

  Future<void> _handleAdd() async {
    if (_potentialMatches.isEmpty || _currentMatchIndex >= _potentialMatches.length) {
      return;
    }
    final currentMatch = _potentialMatches[_currentMatchIndex];
    try {
      // Since there are preloaded profiles, only make Firebase calls on real profiles
      // Make a call indicating that current user has sent a friend request to another user
      if (currentMatch['uid'] != null) {
        await _functions.httpsCallable('sendFriendRequest').call({
          'targetUid': currentMatch['uid'],
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sent Request Successfully')));
      }
      setState(() {
        _currentMatchIndex++;
        if (_currentMatchIndex >= _potentialMatches.length && _hasMoreMatches) {
          _loadPotentialMatches();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending friend request: $e')),
      );
    }
  }

  Widget _buildNoMatchesMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 15),
          Text(
            'There are no more potential matches. Please try again later',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 25),
          ElevatedButton(onPressed: _loadPotentialMatches, child: Text('Refresh'),
          )
        ],
      )
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    return Card(
      color: Color(0xFFF8EFD9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: match['photoURL'] != null
                ? NetworkImage(match['photoURL'])
                : null,
              child: match['photoURL'] == null
                ? Icon(Icons.person, size: 60)
                : null,
            ),
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('${match['firstName']} ${match['lastName']}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),
              ),
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(match['bio'] ?? 'User has not provided a bio',
                style: TextStyle(fontSize: 16),
              )
            ),
            SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Interests:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ...(match['interests'] as List<dynamic>? ?? []).map((interest) => Text('- $interest', style: TextStyle(fontSize: 15)),
                  )
                ],
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleIgnore, 
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
                  child: OutlinedButton(
                    onPressed: _handleAdd, 
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Matchmaking')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _potentialMatches.isEmpty
              ? _buildNoMatchesMessage()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildMatchCard(_potentialMatches[_currentMatchIndex]),
                ),
    );
  }

  /**
   * STATIC SCREEN FOR VISUAL PURPOSES ONLY
   */

  /*
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
  }*/
}
