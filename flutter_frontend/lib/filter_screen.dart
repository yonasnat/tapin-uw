import 'package:flutter/material.dart';
import 'package:tapin/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FilterScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  const FilterScreen({
    Key? key,
    required this.auth,
    required this.firestore,
  }) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Map<String, bool> filters = {
  //   'Computer Science Major': false,
  //   'Engineering Major': false,
  //   'Business Major': false,
  //   'Basketball Player': false,
  //   'Rockclimber': false,
  //   'Artist': false,
  //   'Gamer': false,
  // };
  late Map<String, bool> newFilters;
  late Map<String, bool> originalFilters;

  @override
  void initState() {
    super.initState();
    newFilters = {
      'Computer Science Major': false,
      'Engineering Major': false,
      'Business Major': false,
      'Basketball Player': false,
      'Rockclimber': false,
      'Artist': false,
      'Gamer': false,
    };
    originalFilters = Map.from(newFilters);
    _loadSavedFilters();
  }

  Future<void> _loadSavedFilters() async {
    final user = widget.auth.currentUser;
    if (user == null) return;

    try {
      final doc = await widget.firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null && data['filters'] != null) {
        final savedFilters = List<String>.from(data['filters']);
        setState(() {
          // Update both newFilters and originalFilters with saved values
          for (final filter in newFilters.keys) {
            newFilters[filter] = savedFilters.contains(filter);
          }
          originalFilters = Map.from(newFilters);
        });
      }
    } catch (e) {
      print('Error loading saved filters: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load saved filters: $e')),
      );
    }
  }

  void _onCancel() {
    setState(() {
      newFilters = Map.from(originalFilters);
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  void _onSave() async {
    final user = widget.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save filters')),
      );
      return;
    }

    try {
      // Convert the filters map to a list of enabled filters
      final enabledFilters = newFilters.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Save to Firestore
      await widget.firestore.collection('users').doc(user.uid).update({
        'filters': enabledFilters,
      });

      // Update original filters to match new filters
      setState(() {
        originalFilters = Map.from(newFilters);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filters saved successfully')),
      );

      // Navigate back to main screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      print('Error saving filters: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save filters: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter')),
      // body: ListView.builder(
      //   itemCount: filters.length,
      //   itemBuilder: (context, index) {
      //     final key = filters.keys.toList()[index];
      //     return CheckboxListTile(
      //       title: Text(key),
      //       value: filters[key],
      //       onChanged: (bool? value) {
      //         setState(() {
      //           filters[key] = value ?? false;R
      //           // Coordinate with backend to update filters
      //           // For now, just update the local state
      //         });
      //       },
      //     );
      //   },
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: newFilters.length,
              itemBuilder: (context, index) {
                final key = newFilters.keys.toList()[index];
                return CheckboxListTile(
                  title: Text(key),
                  value: newFilters[key],
                  onChanged: (bool? value) {
                    setState(() {
                      newFilters[key] = value ?? false;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _onCancel,
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Colors.black),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFDDB676)),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
