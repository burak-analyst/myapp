import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  final List<Map<String, String>> _framework = const [
    {
      'title': '1. Vision',
      'desc':
          'Your Vision sets the high-level, long-term direction for different areas of your life (e.g., Health, Finance, Business). It’s your “why” — the ultimate state you want to achieve. You can define your vision statements on the Vision page.'
    },
    {
      'title': '2. Periods',
      'desc':
          'Life is lived in seasons. To make progress manageable, the year is broken into six, two-month Periods (e.g., Jan–Feb, Mar–Apr). This short-term focus helps you concentrate on what’s most important right now without feeling overwhelmed.'
    },
    {
      'title': '3. Objectives',
      'desc':
          'For each Period, you set a few high-impact Objectives. These are significant, concrete goals that align with your long-term Vision. An objective should be ambitious yet achievable within the two-month timeframe.'
    },
    {
      'title': '4. Key Results',
      'desc':
          'How will you know you’ve achieved your objective? Through Key Results. These are measurable outcomes that prove you’ve succeeded. Each objective should have 2–5 Key Results.'
    },
    {
      'title': '5. Tasks',
      'desc':
          'Finally, Tasks are the small, actionable to-do items that help you achieve your Key Results. They are the specific actions you take on a day-to-day or week-to-week basis.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Framework Overview'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade100,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 32),
          children: [
            // HEADER CARD (now inside the ListView, scrolls with content)
            Container(
              margin: const EdgeInsets.only(bottom: 32),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.11),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'The LifeMaxx Framework',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "A simple system for living intentionally, making real progress, and not getting overwhelmed. Here's how it works:",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white70,
                      fontSize: 15.5,
                    ),
                  ),
                ],
              ),
            ),
            ..._framework.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Card(
                    elevation: 3,
                    color: Colors.white.withOpacity(0.98),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                              fontSize: 17,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['desc']!,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14.5,
                              color: Colors.black87,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
