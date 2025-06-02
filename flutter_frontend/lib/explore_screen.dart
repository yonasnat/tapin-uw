import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../theme/colors.dart';

/// TapIn@UW – Static Events Page
/// ------------------------------------------------------------
/// This page shows a list of upcoming UW events using the same
/// brand colours and visual language as the rest of the TapIn
/// mock‑ups you provided.  Plug it into your existing bottom
/// navigation bar or push it on the Navigator stack to test.
/// ------------------------------------------------------------
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  bool _isLoading = true;
  String? _error;
  String? _lastDocId;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _events = [];
        _lastDocId = null;
        _hasMore = true;
        _isLoading = true;
        _error = null;
      });
    }

    if (!_hasMore) return;

    try {
      final events = await _eventService.getEvents(
        status: 'upcoming',
        startAfter: _lastDocId,
      );

      setState(() {
        _events.addAll(events);
        _lastDocId = events.isNotEmpty ? events.last.id : null;
        _hasMore = events.length == 10; // If we got less than 10, we've reached the end
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _joinEvent(String eventId) async {
    try {
      await _eventService.joinEvent(eventId);
      // Refresh the events list to update participant count
      await _loadEvents(refresh: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined event')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppColors.uwPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () => _loadEvents(refresh: true),
        child: _isLoading && _events.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _error != null && _events.isEmpty
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    itemCount: _events.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
                      if (index == _events.length) {
                        _loadEvents();
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final event = _events[index];
          return _EventCard(
                        event: event,
                        onJoin: () => _joinEvent(event.id),
          );
        },
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-event');
        },
        backgroundColor: AppColors.uwPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.onJoin,
  });

  final Event event;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.beige,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navigate to event details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                    ?.copyWith(color: AppColors.navy, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.navy),
                  const SizedBox(width: 6),
                  Text(
                    '${event.date.day}/${event.date.month}/${event.date.year} · ${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: AppColors.navy),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.place_rounded, size: 16, color: AppColors.navy),
                  const SizedBox(width: 6),
                  Text(event.location, style: const TextStyle(color: AppColors.navy)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: -8,
                children: event.tags
                    .map((t) => Chip(
                          label: Text(t),
                          backgroundColor: Colors.white.withOpacity(0.5),
                          labelStyle: const TextStyle(fontSize: 12, color: AppColors.navy),
                          side: const BorderSide(color: AppColors.navy, width: .5),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${event.currentParticipants}/${event.maxParticipants} participants',
                    style: const TextStyle(color: AppColors.navy),
                  ),
                  TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.navy,
                    backgroundColor: Colors.white,
                    minimumSize: const Size(80, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.navy, width: .8),
                      ),
                    ),
                    onPressed: onJoin,
                    child: const Text('Join'),
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
