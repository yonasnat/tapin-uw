import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';

class EventService {
  // Cloud Function URLs
  static const String _getEventsUrl = 'https://getevents-ybcbaxrbca-uc.a.run.app';
  static const String _createEventUrl = 'https://createevent-ybcbaxrbca-uc.a.run.app';
  static const String _joinEventUrl = 'https://joinevent-ybcbaxrbca-uc.a.run.app';
  static const String _leaveEventUrl = 'https://leaveevent-ybcbaxrbca-uc.a.run.app';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  Future<List<Event>> getEvents({
    String? status,
    int limit = 10,
    String? startAfter,
  }) async {
    try {
      final token = await _getIdToken();
      if (token == null) throw Exception('Not authenticated');

      final queryParams = {
        if (status != null) 'status': status,
        'limit': limit.toString(),
        if (startAfter != null) 'startAfter': startAfter,
      };

      final uri = Uri.parse(_getEventsUrl).replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = (data['events'] as List)
            .map((e) => Event.fromMap(e, e['id']))
            .toList();
        return events;
      } else {
        throw Exception('Failed to load events: ${response.body}');
      }
    } catch (e) {
      print('Error getting events: $e');
      rethrow;
    }
  }

  Future<Event> createEvent(Event event) async {
    try {
      final token = await _getIdToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse(_createEventUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(event.toMap()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Event.fromMap(data['event'], data['eventId']);
      } else {
        throw Exception('Failed to create event: ${response.body}');
      }
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  Future<void> joinEvent(String eventId) async {
    try {
      final token = await _getIdToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse(_joinEventUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'eventId': eventId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to join event: ${response.body}');
      }
    } catch (e) {
      print('Error joining event: $e');
      rethrow;
    }
  }

  Future<void> leaveEvent(String eventId) async {
    try {
      final token = await _getIdToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse(_leaveEventUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'eventId': eventId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to leave event: ${response.body}');
      }
    } catch (e) {
      print('Error leaving event: $e');
      rethrow;
    }
  }
} 