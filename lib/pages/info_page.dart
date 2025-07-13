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
      appBar: AppBar(title: const Text('Framework Overview')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _framework.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final item = _framework[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title']!,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                item['desc']!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}
