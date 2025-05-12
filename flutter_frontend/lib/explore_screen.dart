import 'package:flutter/material.dart';

/// TapIn@UW – Static Events Page
/// ------------------------------------------------------------
/// This page shows a list of upcoming UW events using the same
/// brand colours and visual language as the rest of the TapIn
/// mock‑ups you provided.  Plug it into your existing bottom
/// navigation bar or push it on the Navigator stack to test.
/// ------------------------------------------------------------
class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  // ─── Brand Colours ────────────────────────────────────────────────
  static const _uwPurple = Color(0xFF7D3CFF);   // Accent / primary
  static const _beige    = Color(0xFFE9C983);   // Card background
  static const _navy     = Color(0xFF231942);   // Text / icon

  // ─── Mock Event Data ──────────────────────────────────────────────
  static const _events = [
    {
      'title': 'Husky Hackathon',
      'date': 'Fri, May 16 · 6 PM',
      'location': 'Allen Center Atrium',
      'tags': ['CS', '24 hrs', 'Free Pizza']
    },
    {
      'title': 'Cherry‑Blossom Photo Walk',
      'date': 'Sat, May 17 · 10 AM',
      'location': 'Quad – UW Campus',
      'tags': ['Photography', 'Outdoors']
    },
    {
      'title': 'Intro to Rock‑Climbing Clinic',
      'date': 'Sun, May 18 · 2 PM',
      'location': 'U‑District Edgeworks',
      'tags': ['Rock Climbing', 'Beginner']
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: _uwPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: _events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final e = _events[index];
          return _EventCard(
            title: e['title'] as String,
            date: e['date'] as String,
            location: e['location'] as String,
            tags: (e['tags'] as List<String>).cast<String>(),
          );
        },
      ),
      // bottomNavigationBar: _SimpleNavBar(currentIndex: 0),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.title,
    required this.date,
    required this.location,
    required this.tags,
  });

  final String title;
  final String date;
  final String location;
  final List<String> tags;

  static const _beige = EventsPage._beige;
  static const _navy  = EventsPage._navy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _beige,
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
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: _navy, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: _navy),
                  const SizedBox(width: 6),
                  Text(date, style: TextStyle(color: _navy)),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.place_rounded, size: 16, color: _navy),
                  const SizedBox(width: 6),
                  Text(location, style: TextStyle(color: _navy)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: -8,
                children: tags
                    .map((t) => Chip(
                          label: Text(t),
                          backgroundColor: Colors.white.withOpacity(.9),
                          labelStyle: const TextStyle(fontSize: 12, color: _navy),
                          side: const BorderSide(color: _navy, width: .5),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: _navy,
                    backgroundColor: Colors.white,
                    minimumSize: const Size(80, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: _navy, width: .8),
                    ),
                  ),
                  onPressed: () {}, // TODO: implement join logic
                  child: const Text('Join'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
