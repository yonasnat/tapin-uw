import 'package:flutter/material.dart';
import 'package:tapin/app.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

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

  void _onSave() {
    // Add the backend functionality to save each filter for the user
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
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
