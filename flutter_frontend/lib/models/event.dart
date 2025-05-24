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
  final String? imageUrl;
  final String organizerId;
  final String status;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.tags,
    this.imageUrl,
    required this.organizerId,
    required this.status,
    required this.createdAt,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      maxParticipants: data['maxParticipants'] ?? 0,
      currentParticipants: data['currentParticipants'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      imageUrl: data['imageUrl'],
      organizerId: data['organizerId'] ?? '',
      status: data['status'] ?? 'upcoming',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'location': location,
      'description': description,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'tags': tags,
      'imageUrl': imageUrl,
      'organizerId': organizerId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? location,
    String? description,
    int? maxParticipants,
    int? currentParticipants,
    List<String>? tags,
    String? imageUrl,
    String? organizerId,
    String? status,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      organizerId: organizerId ?? this.organizerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}