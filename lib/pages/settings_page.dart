import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/objective.dart';
import '../models/key_result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _name;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name');
      if (_name != null) _nameController.text = _name!;
    });
  }

  Future<void> _saveName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    setState(() {
      _name = _nameController.text.trim();
    });
    Navigator.pop(context);
  }

  Future<void> _showNameDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("What's your name?"),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: "Enter your name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _saveName,
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCSV() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('objectives') ?? [];
    List<Objective> objectives = [];
    for (final jsonStr in jsonList) {
      final obj = json.decode(jsonStr);
      objectives.add(
        Objective(
          title: obj['title'],
          status: Status.values.firstWhere((s) => s.name == obj['status']),
          category: obj['category'],
          year: obj['year'],
          periodIndex: obj['periodIndex'],
          keyResults: (obj['keyResults'] as List).map((kr) {
            return KeyResult(
              title: kr['title'],
              status: Status.values.firstWhere((s) => s.name == kr['status']),
              tasks: List<String>.from(kr['tasks']),
            );
          }).toList(),
        ),
      );
    }

    // Build CSV string
    StringBuffer buffer = StringBuffer();
    buffer.writeln('Category,Year,Period,Objective,Status,Key Result,KR Status,Task');
    for (var obj in objectives) {
      if (obj.keyResults.isEmpty) {
        buffer.writeln(
          '${obj.category},${obj.year},${obj.periodIndex},${obj.title},${obj.status.name},,,'
        );
      } else {
        for (var kr in obj.keyResults) {
          if (kr.tasks.isEmpty) {
            buffer.writeln(
              '${obj.category},${obj.year},${obj.periodIndex},${obj.title},${obj.status.name},${kr.title},${kr.status.name},'
            );
          } else {
            for (var task in kr.tasks) {
              buffer.writeln(
                '${obj.category},${obj.year},${obj.periodIndex},${obj.title},${obj.status.name},${kr.title},${kr.status.name},${task.replaceAll(",", ";")}'
              );
            }
          }
        }
      }
    }

    // Save CSV to file
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/lifemaxx_data.csv');
    await file.writeAsString(buffer.toString());

    // Share CSV file
    await Share.shareXFiles([XFile(file.path)], text: 'Here is my LifeMaxx data export!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_name != null && _name!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blueGrey[100],
                    child: const Icon(Icons.person, size: 30, color: Colors.blueGrey),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Welcome, $_name!',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueGrey),
                    onPressed: _showNameDialog,
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: ListTile(
                leading: const Icon(Icons.person_outline, size: 30, color: Colors.blueGrey),
                title: const Text(
                  'Tap to enter your name',
                  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                ),
                onTap: _showNameDialog,
              ),
            ),
          const Text(
            'Account',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Export Data'),
            subtitle: const Text('Export your objectives, key results, and tasks to CSV'),
            onTap: _exportCSV,
          ),
        ],
      ),
    );
  }
}
