import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  void initState() {
    super.initState();
    _loadVisions();
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadVisions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var category in _controllers.keys) {
        _controllers[category]?.text = prefs.getString('vision_$category') ?? '';
      }
    });
  }

  Future<void> _saveVision(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vision_$category', _controllers[category]!.text);
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
                      icon: const Icon(Icons.save),
                      onPressed: () => _saveVision(entry.key),
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
