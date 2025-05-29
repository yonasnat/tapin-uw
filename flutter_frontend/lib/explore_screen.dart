import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tapin/models/event.dart';
import 'package:tapin/create_event_screen.dart';

/// TapIn@UW – Static Events Page
/// ------------------------------------------------------------
/// This page shows a list of upcoming UW events using the same
/// brand colours and visual language as the rest of the TapIn
/// mock‑ups you provided.  Plug it into your existing bottom
/// navigation bar or push it on the Navigator stack to test.
/// ------------------------------------------------------------
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  // Make colors static and accessible to _EventCard
  static const uwPurple = Color(0xFF7D3CFF);   // Accent / primary
  static const beige = Color(0xFFE9C983);   // Card background
  static const navy = Color(0xFF231942);   // Text / icon

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Event> events = [];
  bool loading = true;
  String? lastDocId;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final query = FirebaseFirestore.instance
          .collection('events')
          .where('date', isGreaterThanOrEqualTo: DateTime.now())
          .orderBy('date', descending: false)
          .limit(10);

      if (lastDocId != null) {
        final lastDoc = await FirebaseFirestore.instance
            .collection('events')
            .doc(lastDocId)
            .get();
        query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        setState(() {
          hasMore = false;
          loading = false;
        });
        return;
      }

      final newEvents = snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
      
      setState(() {
        events.addAll(newEvents);
        lastDocId = snapshot.docs.last.id;
        hasMore = newEvents.length == 10;
        loading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
      setState(() => loading = false);
    }
  }

  Future<void> handleJoinEvent(Event event) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final eventRef = FirebaseFirestore.instance.collection('events').doc(event.id);
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final eventDoc = await transaction.get(eventRef);
        if (!eventDoc.exists) return;

        final eventData = eventDoc.data()!;
        final participants = List<String>.from(eventData['participants'] ?? []);
        
        if (participants.contains(user.uid)) {
          // User is already joined, so unjoin
          participants.remove(user.uid);
          transaction.update(eventRef, {
            'participants': participants,
            'currentParticipants': FieldValue.increment(-1)
          });
          transaction.update(userRef, {
            'joinedEvents': FieldValue.arrayRemove([event.id])
          });
        } else {
          // User is not joined, so join
          if (event.currentParticipants >= event.maxParticipants) {
            throw Exception('Event is full');
          }
          participants.add(user.uid);
          transaction.update(eventRef, {
            'participants': participants,
            'currentParticipants': FieldValue.increment(1)
          });
          transaction.update(userRef, {
            'joinedEvents': FieldValue.arrayUnion([event.id])
          });
        }
      });

      // Refresh the events list
      setState(() {
        events = [];
        lastDocId = null;
        hasMore = true;
        loading = true;
      });
      await fetchEvents();
    } catch (e) {
      print('Error joining/unjoining event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: EventsPage.uwPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateEventScreen()),
              ).then((_) {
                // Refresh events when returning from create screen
                setState(() {
                  events = [];
                  lastDocId = null;
                  hasMore = true;
                  loading = true;
                });
                fetchEvents();
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? const Center(child: Text('No events found'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  itemCount: events.length + (hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index == events.length) {
                      fetchEvents(); // Load more events
                      return const Center(child: CircularProgressIndicator());
                    }
                    final event = events[index];
                    return _EventCard(
                      event: event,
                      onJoin: () => handleJoinEvent(event),
                    );
                  },
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
class _EventCard extends StatefulWidget {
  const _EventCard({
    required this.event,
    required this.onJoin,
  });

  final Event event;
  final VoidCallback onJoin;

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  bool isJoined = false;

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    checkJoinStatus();
  }

  Future<void> checkJoinStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final joinedEvents = List<String>.from(doc.data()?['joinedEvents'] ?? []);
      setState(() {
        isJoined = joinedEvents.contains(widget.event.id);
      });
    } catch (e) {
      print('Error checking join status: $e');
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('events').doc(widget.event.id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting event: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EventsPage.beige,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {}, // TODO: push detail page
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.event.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: EventsPage.navy, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (widget.event.organizerId == currentUserId)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Event',
                      onPressed: _deleteEvent,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: EventsPage.navy),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year} at ${widget.event.date.hour}:${widget.event.date.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: EventsPage.navy),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.place_rounded, size: 16, color: EventsPage.navy),
                  const SizedBox(width: 6),
                  Text(widget.event.location, style: TextStyle(color: EventsPage.navy)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: -8,
                children: widget.event.tags
                    .map((t) => Chip(
                          label: Text(t),
                          backgroundColor: Colors.white.withOpacity(0.5),
                          labelStyle: const TextStyle(fontSize: 12, color: EventsPage.navy),
                          side: const BorderSide(color: EventsPage.navy, width: .5),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.event.currentParticipants}/${widget.event.maxParticipants} participants',
                    style: TextStyle(color: EventsPage.navy),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: isJoined ? Colors.white : EventsPage.navy,
                      backgroundColor: isJoined ? EventsPage.uwPurple : Colors.white,
                      minimumSize: const Size(80, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isJoined ? EventsPage.uwPurple : EventsPage.navy,
                          width: .8,
                        ),
                      ),
                    ),
                    onPressed: widget.event.currentParticipants >= widget.event.maxParticipants && !isJoined
                        ? null
                        : () {
                            setState(() => isJoined = !isJoined);
                            widget.onJoin();
                          },
                    child: Text(isJoined ? 'Unjoin' : 'Join'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
