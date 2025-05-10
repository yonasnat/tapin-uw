import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  Map<String, bool> filters = {
    'Computer Science Major': false,
    'Engineering Major': false,
    'Business Major': false,
    'Basketball Player': false,
    'Rockclimber': false,
    'Artist': false,
    'Gamer': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter')),
      body: ListView.builder(
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final key = filters.keys.toList()[index];
          return CheckboxListTile(
            title: Text(key),
            value: filters[key],
            onChanged: (bool? value) {
              setState(() {
                filters[key] = value ?? false;
                // Coordinate with backend to update filters
                // For now, just update the local state
              });
            },
          );
        },
      ),
    );
  }
}
