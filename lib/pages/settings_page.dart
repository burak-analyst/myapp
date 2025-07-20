import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/objective.dart';
import '../models/key_result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
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

  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String csv = await file.readAsString();

      // Confirm overwrite
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Data'),
          content: const Text(
              'This will overwrite ALL your existing objectives with data from the CSV. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      // Parse CSV and overwrite SharedPreferences
      List<Objective> importedObjectives = _parseCSV(csv);
      final prefs = await SharedPreferences.getInstance();
      List<String> jsonList = importedObjectives.map((o) {
        return json.encode({
          'title': o.title,
          'status': o.status.name,
          'category': o.category,
          'year': o.year,
          'periodIndex': o.periodIndex,
          'keyResults': o.keyResults.map((kr) => {
            'title': kr.title,
            'status': kr.status.name,
            'tasks': kr.tasks,
          }).toList(),
        });
      }).toList();

      await prefs.setStringList('objectives', jsonList);

      // Success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully!')),
        );
      }
    }
  }

  List<Objective> _parseCSV(String csv) {
    List<String> lines = csv.split('\n');
    if (lines.isNotEmpty && lines.first.trim().toLowerCase().contains("category")) {
      lines = lines.sublist(1); // remove header
    }
    Map<String, Objective> objectives = {};

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final fields = _parseCsvLine(line);

      if (fields.length < 8) continue;
      final cat = fields[0];
      final year = int.tryParse(fields[1]) ?? DateTime.now().year;
      final period = int.tryParse(fields[2]) ?? 0;
      final objTitle = fields[3];
      final objStatus = Status.values.firstWhere(
        (s) => s.name == fields[4],
        orElse: () => Status.notStarted,
      );
      final krTitle = fields[5];
      final krStatus = Status.values.firstWhere(
        (s) => s.name == fields[6],
        orElse: () => Status.notStarted,
      );
      final task = fields[7];

      final objKey = '$cat|$year|$period|$objTitle';

      if (!objectives.containsKey(objKey)) {
        objectives[objKey] = Objective(
          title: objTitle,
          status: objStatus,
          category: cat,
          year: year,
          periodIndex: period,
          keyResults: [],
        );
      }
      final obj = objectives[objKey];

      if (krTitle.isNotEmpty) {
        var existingKR = obj!.keyResults.where((kr) => kr.title == krTitle).toList();
        if (existingKR.isEmpty) {
          obj.keyResults.add(KeyResult(
            title: krTitle,
            status: krStatus,
            tasks: task.isNotEmpty ? [task] : [],
          ));
        } else {
          if (task.isNotEmpty) existingKR.first.tasks.add(task);
        }
      }
    }
    return objectives.values.toList();
  }

  // Simple CSV parser for a line
  List<String> _parseCsvLine(String line) {
    List<String> out = [];
    String current = '';
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"' && (i == 0 || line[i - 1] != '\\')) {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        out.add(current);
        current = '';
      } else {
        current += char;
      }
    }
    out.add(current);
    return out;
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
          ListTile(
            leading: Icon(Icons.file_download), // <-- FIXED ICON HERE
            title: const Text('Import Data'),
            subtitle: const Text('Import/restore your objectives from CSV (will overwrite all data)'),
            onTap: _importCSV,
          ),
        ],
      ),
    );
  }
}
