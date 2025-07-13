import 'package:flutter/material.dart';
import '../models/objective.dart';
import '../models/key_result.dart';

class ObjectivesPage extends StatefulWidget {
  const ObjectivesPage({super.key});

  @override
  State<ObjectivesPage> createState() => _ObjectivesPageState();
}

class _ObjectivesPageState extends State<ObjectivesPage> {
  final List<Objective> _objectives = [];

  final List<String> _categories = [
    'Health',
    'Finance',
    'Business',
    'Romance',
    'Lifestyle',
  ];

  final List<String> _periods = [
    'Jan–Feb',
    'Mar–Apr',
    'May–Jun',
    'Jul–Aug',
    'Sep–Oct',
    'Nov–Dec',
  ];

  int _selectedYear = DateTime.now().year;
  int _selectedPeriodIndex = 0;
  String _selectedCategory = 'Health';

  List<int> get _yearRange => List.generate(4, (i) => DateTime.now().year + i);

  List<Objective> get _filteredObjectives => _objectives.where((obj) {
        return obj.year == _selectedYear &&
            obj.periodIndex == _selectedPeriodIndex &&
            obj.category == _selectedCategory;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Objectives')),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredObjectives.length,
              itemBuilder: (context, index) {
                final obj = _filteredObjectives[index];
                return _buildObjectiveCard(obj);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddObjectiveDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Objective'),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            items: _categories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedYear = (_selectedYear - 1).clamp(_yearRange.first, _yearRange.last);
                      });
                    },
                  ),
                  Text('$_selectedYear'),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      setState(() {
                        _selectedYear = (_selectedYear + 1).clamp(_yearRange.first, _yearRange.last);
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

  Widget _buildObjectiveCard(Objective obj) {
    return ExpansionTile(
      title: Row(
        children: [
          Expanded(child: Text(obj.title)),
          _statusTag(obj.status),
        ],
      ),
      backgroundColor: _statusColor(obj.status),
      collapsedBackgroundColor: _statusColor(obj.status),
      collapsedTextColor: _statusTextColor(obj.status),
      textColor: _statusTextColor(obj.status),
      children: [
        for (int i = 0; i < obj.keyResults.length; i++)
          ListTile(
            title: Text('• ${obj.keyResults[i].title}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var task in obj.keyResults[i].tasks) Text('    - $task'),
                TextButton.icon(
                  onPressed: () => _addTask(obj, i),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                ),
              ],
            ),
            trailing: _statusTag(obj.keyResults[i].status),
          ),
        TextButton.icon(
          onPressed: () => _addKeyResult(obj),
          icon: const Icon(Icons.add),
          label: const Text('Add Key Result'),
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
          title: const Text('New Objective'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Objective Title'),
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
              child: const Text('Cancel'),
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
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addKeyResult(Objective obj) {
    final controller = TextEditingController();
    Status krStatus = Status.notStarted;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Key Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Key Result Title'),
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  obj.keyResults.add(KeyResult(title: controller.text, status: krStatus, tasks: []));
                });
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addTask(Objective obj, int krIndex) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Task'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() => obj.keyResults[krIndex].tasks.add(controller.text));
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
