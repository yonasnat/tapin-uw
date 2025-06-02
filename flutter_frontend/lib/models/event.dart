import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String description;
  final int maxParticipants;
  final int currentParticipants;
  final List<String> tags;
  final String organizerId;
  final String status;
  final DateTime createdAt;
  final String? imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.tags,
    required this.organizerId,
    required this.status,
    required this.createdAt,
    this.imageUrl,
  });

  factory Event.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is Map<String, dynamic>) {
        // Handle Firestore Timestamp format
        if (dateValue['_seconds'] != null) {
          return DateTime.fromMillisecondsSinceEpoch(dateValue['_seconds'] * 1000);
        }
        // Handle JSON date format from Cloud Functions
        return DateTime.parse(dateValue.toString());
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else {
        throw Exception('Invalid date format: $dateValue');
      }
    }

    return Event(
      id: docId,
      title: map['title'] ?? '',
      date: parseDate(map['date']),
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      maxParticipants: map['maxParticipants'] ?? 0,
      currentParticipants: map['currentParticipants'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      organizerId: map['organizerId'] ?? '',
      status: map['status'] ?? 'upcoming',
      createdAt: parseDate(map['createdAt']),
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'tags': tags,
      'organizerId': organizerId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
} 