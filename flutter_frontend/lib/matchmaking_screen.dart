import 'dart:convert';
//
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;



class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});
  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}


class _MatchmakingScreenState extends State<MatchmakingScreen> {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  List<Map<String, dynamic>> _potentialMatches = [];
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadPotentialMatches();
  }








  Future<void> _loadPotentialMatches() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _potentialMatches = [];
      });
      return;
    }

    try {
      // Get current user's filters and matchActions
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final userFilters = List<String>.from(userData?['filters'] ?? []);
      final matchActions = Map<String, dynamic>.from(userData?['matchActions'] ?? {});

      // Get all users
      final allUsersSnapshot = await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>> matches = [];
      for (var doc in allUsersSnapshot.docs) {
        if (doc.id == user.uid) continue; // skip self
        if (matchActions.containsKey(doc.id)) continue; // skip already acted on

        final otherData = doc.data();
        final otherFilters = List<String>.from(otherData['filters'] ?? []);
        if (otherFilters.isEmpty) continue; // skip users with no filters selected
        // Count common filters
        final commonCount = otherFilters.where((f) => userFilters.contains(f)).length;
        final match = Map<String, dynamic>.from(otherData);
        match['uid'] = doc.id;
        match['commonFilterCount'] = commonCount;
        matches.add(match);
      }

      // Sort: first by descending commonFilterCount, then by uid (or any other tiebreaker)
      matches.sort((a, b) {
        int cmp = (b['commonFilterCount'] as int).compareTo(a['commonFilterCount'] as int);
        if (cmp != 0) return cmp;
        return (a['uid'] as String).compareTo(b['uid'] as String);
      });

      setState(() {
        _potentialMatches = matches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _potentialMatches = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading matches: $e'), duration: Duration(milliseconds: 500)),
      );
    }
  }








  Future<void> _handleIgnore(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to ignore matches'), duration: Duration(milliseconds: 500)),
      );
      return;
    }

    try {
      final match = _potentialMatches[index];
      final matchUid = match['uid'];

      // Save to Firestore as a map field on the user document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'matchActions': {
          matchUid: {
            'action': 'ignore',
            'actedAt': FieldValue.serverTimestamp(),
          }
        }
      }, SetOptions(merge: true));

      setState(() {
        _potentialMatches.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match ignored'), duration: Duration(milliseconds: 500)),
      );
    } catch (e) {
      print('Error ignoring match: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ignore match: $e'), duration: Duration(milliseconds: 500)),
      );
    }
  }








  Future<void> _handleSave(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save matches'), duration: Duration(milliseconds: 500)),
      );
      return;
    }

    try {
      final match = _potentialMatches[index];
      final matchUid = match['uid'];

      // Save to Firestore as a map field on the user document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'matchActions': {
          matchUid: {
            'action': 'save',
            'actedAt': FieldValue.serverTimestamp(),
          }
        }
      }, SetOptions(merge: true));

      setState(() {
        _potentialMatches.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match saved'), duration: Duration(milliseconds: 500)),
      );
    } catch (e) {
      print('Error saving match: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save match: $e'), duration: Duration(milliseconds: 500)),
      );
    }
  }








  Widget _buildNoMatchesMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          'No recommended matches at the moment.',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }








  Widget _buildMatchCard(Map<String, dynamic> match, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: const Color(0xFFF8EFD9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: match['photoURL'] != null && match['photoURL'] != ''
                      ? NetworkImage(match['photoURL'])
                      : null,
                  child: (match['photoURL'] == null || match['photoURL'] == '')
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match['displayName'] ?? 'Unnamed',
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Common Filters: ${match['commonFilterCount'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (match['bio'] != null && match['bio'].toString().isNotEmpty) ...[
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                match['bio'] ?? 'No bio provided',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (match['filters'] as List<dynamic>? ?? [])
                  .map((filter) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDB676),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleIgnore(index),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Ignore',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleSave(index),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFDDB676),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16),
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








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matchmaking'),
        backgroundColor: Color(0xFF7D3CFF), // Use the same purple as Events
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _potentialMatches.isEmpty
              ? _buildNoMatchesMessage()
              : RefreshIndicator(
                  onRefresh: _loadPotentialMatches,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                    itemCount: _potentialMatches.length,
                    itemBuilder: (context, index) {
                      final match = _potentialMatches[index];
                      return _buildMatchCard(match, index);
                    },
                  ),
                ),
    );
  }
}







