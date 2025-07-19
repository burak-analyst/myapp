import 'package:flutter/material.dart';
import '../models/objective.dart';
import '../models/key_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ObjectivesPage extends StatefulWidget {
  const ObjectivesPage({super.key});

  @override
  State<ObjectivesPage> createState() => _ObjectivesPageState();
}

class _ObjectivesPageState extends State<ObjectivesPage> {
  final List<Objective> _objectives = [];

  final List<String> _categories = [
    'health',
    'finance',
    'business',
    'romance',
    'lifestyle',
  ];

  final List<String> _periods = [
    'jan-feb',
    'mar-apr',
    'may-jun',
    'jul-aug',
    'sep-oct',
    'nov-dec',
  ];

  int _selectedYear = DateTime.now().year;
  int _selectedPeriodIndex = 3; // Default to Jul-Aug (July 19, 2025)
  String _selectedCategory = 'health';

  List<int> get _yearRange => List.generate(4, (i) => DateTime.now().year + i);

  List<Objective> get _filteredObjectives => _objectives.where((obj) {
        return obj.year == _selectedYear &&
            obj.periodIndex == _selectedPeriodIndex &&
            obj.category == _selectedCategory;
      }).toList();

  @override
  void initState() {
    super.initState();
    _loadObjectivesFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('objectives')),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredObjectives.length,
              itemBuilder: (context, index) {
                final obj = _filteredObjectives[index];
                return _buildObjectiveCard(obj, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddObjectiveDialog,
        icon: const Icon(Icons.add),
        label: const Text('new objective'),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedYear =
                            (_selectedYear - 1).clamp(_yearRange.first, _yearRange.last);
                      });
                    },
                  ),
                  Text('$_selectedYear'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      setState(() {
                        _selectedYear =
                            (_selectedYear + 1).clamp(_yearRange.first, _yearRange.last);
                      });
                    },
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _periods[_selectedPeriodIndex],
                items: List.generate(_periods.length, (i) {
                  return DropdownMenuItem(
                    value: _periods[i],
                    child: Text(_periods[i]),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriodIndex = _periods.indexOf(value);
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveCard(Objective obj, int objIndex) {
    return ExpansionTile(
      title: Row(
        children: [
          Expanded(child: Text(obj.title)),
          _statusTag(obj.status),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditObjectiveDialog(obj, objIndex),
          ),
        ],
      ),
      backgroundColor: _statusColor(obj.status),
      collapsedBackgroundColor: _statusColor(obj.status),
      collapsedTextColor: _statusTextColor(obj.status),
      textColor: _statusTextColor(obj.status),
      children: [
        for (int i = 0; i < obj.keyResults.length; i++)
          ListTile(
            title: Row(
              children: [
                Expanded(child: Text(obj.keyResults[i].title)),
                _statusTag(obj.keyResults[i].status),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditKeyResultDialog(obj, i, objIndex),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var task in obj.keyResults[i].tasks)
                  Row(
                    children: [
                      Expanded(child: Text('  - $task')),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditTaskDialog(obj, i, task, objIndex),
                      ),
                    ],
                  ),
                TextButton.icon(
                  onPressed: () => _addTask(obj, i, objIndex),
                  icon: const Icon(Icons.add),
                  label: const Text('add task'),
                ),
              ],
            ),
            trailing: _statusTag(obj.keyResults[i].status),
          ),
        TextButton.icon(
          onPressed: () => _addKeyResult(obj, objIndex),
          icon: const Icon(Icons.add),
          label: const Text('add key result'),
        ),
      ],
    );
  }

  void _showAddObjectiveDialog() {
    final controller = TextEditingController();
    Status selectedStatus = Status.notStarted;
    String selectedCategory = _selectedCategory;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('new objective'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'objective title'),
              ),
              const SizedBox(height: 16),
              DropdownButton<Status>(
                value: selectedStatus,
                isExpanded: true,
                items: Status.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedStatus = val);
                },
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _objectives.add(
                    Objective(
                      title: controller.text,
                      status: selectedStatus,
                      category: selectedCategory,
                      year: _selectedYear,
                      periodIndex: _selectedPeriodIndex,
                      keyResults: [],
                    ),
                  );
                });
                _saveObjectivesToPrefs();
                Navigator.pop(context);
              },
              child: const Text('add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditObjectiveDialog(Objective obj, int objIndex) {
    final controller = TextEditingController(text: obj.title);
    Status selectedStatus = obj.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('edit objective'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'objective title'),
              ),
              const SizedBox(height: 16),
              DropdownButton<Status>(
                value: selectedStatus,
                isExpanded: true,
                items: Status.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedStatus = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _objectives[objIndex].title = controller.text;
                  _objectives[objIndex].status = selectedStatus;
                });
                _saveObjectivesToPrefs();
                Navigator.pop(context);
              },
              child: const Text('save'),
            ),
          ],
        );
      },
    );
  }

  void _addKeyResult(Objective obj, int objIndex) {
    final controller = TextEditingController();
    Status krStatus = Status.notStarted;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('add key result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'key result title'),
              ),
              const SizedBox(height: 16),
              DropdownButton<Status>(
                value: krStatus,
                isExpanded: true,
                items: Status.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => krStatus = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  obj.keyResults.add(KeyResult(title: controller.text, status: krStatus, tasks: []));
                });
                _saveObjectivesToPrefs();
                Navigator.pop(context);
              },
              child: const Text('add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditKeyResultDialog(Objective obj, int krIndex, int objIndex) {
    final controller = TextEditingController(text: obj.keyResults[krIndex].title);
    Status selectedStatus = obj.keyResults[krIndex].status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('edit key result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'key result title'),
              ),
              const SizedBox(height: 16),
              DropdownButton<Status>(
                value: selectedStatus,
                isExpanded: true,
                items: Status.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedStatus = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  obj.keyResults[krIndex].title = controller.text;
                  obj.keyResults[krIndex].status = selectedStatus;
                });
                _saveObjectivesToPrefs();
                Navigator.pop(context);
              },
              child: const Text('save'),
            ),
          ],
        );
      },
    );
  }

  void _addTask(Objective obj, int krIndex, int objIndex) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('add task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'task'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => obj.keyResults[krIndex].tasks.add(controller.text));
              _saveObjectivesToPrefs();
              Navigator.pop(context);
            },
            child: const Text('add'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(Objective obj, int krIndex, String task, int objIndex) {
    final controller = TextEditingController(text: task);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('edit task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'task'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final taskIndex = obj.keyResults[krIndex].tasks.indexOf(task);
                if (taskIndex != -1) {
                  obj.keyResults[krIndex].tasks[taskIndex] = controller.text;
                }
              });
              _saveObjectivesToPrefs();
              Navigator.pop(context);
            },
            child: const Text('save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveObjectivesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _objectives.map((o) => json.encode({
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
        })).toList();
    await prefs.setStringList('objectives', jsonList);
  }

  Future<void> _loadObjectivesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('objectives') ?? [];

    setState(() {
      _objectives.clear();
      for (final jsonStr in jsonList) {
        final obj = json.decode(jsonStr);
        _objectives.add(
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
    });
  }

  Widget _statusTag(Status status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusTextColor(status),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Color _statusColor(Status status) {
    switch (status) {
      case Status.notStarted:
        return Colors.blue.shade100;
      case Status.inProgress:
        return Colors.orange.shade100;
      case Status.done:
        return Colors.green.shade300;
    }
  }

  Color _statusTextColor(Status status) {
    switch (status) {
      case Status.notStarted:
        return Colors.blue;
      case Status.inProgress:
        return Colors.orange;
      case Status.done:
        return Colors.green.shade800;
    }
  }
}