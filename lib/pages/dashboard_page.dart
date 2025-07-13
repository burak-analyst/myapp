import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Objectives Status by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _categoryRow('Health', done: 2, inProgress: 1, notStarted: 1),
          _categoryRow('Finance', done: 1, inProgress: 2, notStarted: 0),
          _categoryRow('Business', done: 0, inProgress: 1, notStarted: 1),
          const SizedBox(height: 32),
          const Text(
            'Key Results Status by Objective',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _objectiveRow('Lose 15 kg', done: 2, inProgress: 1, notStarted: 0),
          _objectiveRow('Save \$5000', done: 1, inProgress: 0, notStarted: 1),
        ],
      ),
    );
  }

  Widget _categoryRow(String title, {int done = 0, int inProgress = 0, int notStarted = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: [
            _statusBar('Done', done, Colors.green),
            _statusBar('In Progress', inProgress, Colors.orange),
            _statusBar('Not Started', notStarted, Colors.blue),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _objectiveRow(String title, {int done = 0, int inProgress = 0, int notStarted = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• $title', style: const TextStyle(fontWeight: FontWeight.w500)),
        Row(
          children: [
            _statusBar('Done', done, Colors.green),
            _statusBar('In Progress', inProgress, Colors.orange),
            _statusBar('Not Started', notStarted, Colors.blue),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

Widget _statusBar(String label, int count, Color color) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        height: 16,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            '$label: $count',
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.9)),
          ),
        ),
      ),
    ),
  );
}

}
