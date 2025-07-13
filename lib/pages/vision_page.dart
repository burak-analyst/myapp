import 'package:flutter/material.dart';

class VisionPage extends StatefulWidget {
  const VisionPage({super.key});

  @override
  State<VisionPage> createState() => _VisionPageState();
}

class _VisionPageState extends State<VisionPage> {
  final Map<String, TextEditingController> _controllers = {
    'Health': TextEditingController(),
    'Finance': TextEditingController(),
    'Business': TextEditingController(),
    'Romance': TextEditingController(),
    'Lifestyle': TextEditingController(),
  };

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Life Vision')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _controllers.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key.toUpperCase()} Vision',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: entry.value,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write your ideal state for ${entry.key.toLowerCase()}...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => entry.value.clear()),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
