import 'package:flutter/material.dart';
import '../models/objective.dart';
import '../models/key_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'objectives_components.dart';

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
    'Jan-Feb',
    'Mar-Apr',
    'May-Jun',
    'Jul-Aug',
    'Sep-Oct',
    'Nov-Dec',
  ];

  int _selectedYear = DateTime.now().year;
  int _selectedPeriodIndex = 3;

  List<int> get _yearRange => List.generate(4, (i) => DateTime.now().year + i);

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() async {
    await _loadObjectivesFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 6,
        title: const Text(
          'Objectives',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.3,
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Reload',
            onPressed: () => _initLoad(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueGrey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: _categories.length,
                itemBuilder: (context, catIndex) {
                  final cat = _categories[catIndex];
                  final categoryObjectives = _objectives.where((obj) =>
                      obj.year == _selectedYear &&
                      obj.periodIndex == _selectedPeriodIndex &&
                      obj.category == cat
                  ).toList();

                  return ExpansionTile(
                    initiallyExpanded: categoryObjectives.isNotEmpty,
                    leading: Icon(_categoryIcon(cat), color: Colors.blueGrey[700]),
                    title: Text(
                      cat,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Colors.blueGrey,
                        letterSpacing: 0.3,
                      ),
                    ),
                    children: categoryObjectives.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, left: 18),
                              child: Text(
                                "No objectives in this category.",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  color: Colors.blueGrey[300],
                                ),
                              ),
                            )
                          ]
                        : categoryObjectives.map((obj) {
                            return buildObjectiveCardWidget(
                              context: context,
                              obj: obj,
                              objIndex: _objectives.indexOf(obj),
                              onEditObjective: _showEditObjectiveDialog,
                              onDeleteObjective: _deleteObjective,
                              onEditKeyResult: _showEditKeyResultDialog,
                              onDeleteKeyResult: _deleteKeyResult,
                              onAddKeyResult: _addKeyResult,
                              onEditTask: _showEditTaskDialog,
                              onDeleteTask: _deleteTask,
                              onAddTask: _addTask,
                              onStatusChange: _onStatusChange,
                            );
                          }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddObjectiveDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Objective',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
        elevation: 6,
      ),
    );
  }

  Widget _buildFilters() {
    return buildFiltersWidget(
      context: context,
      selectedYear: _selectedYear,
      onYearChanged: (year) => setState(() => _selectedYear = year),
      yearRange: _yearRange,
      periods: _periods,
      selectedPeriodIndex: _selectedPeriodIndex,
      onPeriodChanged: (index) => setState(() => _selectedPeriodIndex = index),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'health':
        return Icons.favorite_rounded;
      case 'finance':
        return Icons.attach_money_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'romance':
        return Icons.favorite_border_rounded;
      case 'lifestyle':
        return Icons.style_rounded;
      default:
        return Icons.category;
    }
  }

  void _showAddObjectiveDialog() {
    showAddObjectiveDialog(
      context: context,
      categories: _categories,
      selectedCategory: _categories.first,
      selectedYear: _selectedYear,
      selectedPeriodIndex: _selectedPeriodIndex,
      onAdd: (Objective obj) {
        setState(() {
          _objectives.add(obj);
        });
        _saveObjectivesToPrefs();
      },
    );
  }

  void _showEditObjectiveDialog(Objective obj, int objIndex) {
    showEditObjectiveDialog(
      context: context,
      obj: obj,
      categories: _categories,
      onSave: (String title, Status status, String category) {
        setState(() {
          _objectives[objIndex].title = title;
          _objectives[objIndex].status = status;
          _objectives[objIndex].category = category;
        });
        _saveObjectivesToPrefs();
      },
    );
  }

  void _deleteObjective(int objIndex) {
    setState(() {
      _objectives.removeAt(objIndex);
    });
    _saveObjectivesToPrefs();
  }

  void _addKeyResult(Objective obj, int objIndex) {
    showAddKeyResultDialog(
      context: context,
      onAdd: (KeyResult kr) {
        setState(() {
          obj.keyResults.add(kr);
        });
        _saveObjectivesToPrefs();
      },
    );
  }

  void _showEditKeyResultDialog(Objective obj, int krIndex, int objIndex) {
    showEditKeyResultDialog(
      context: context,
      keyResult: obj.keyResults[krIndex],
      onSave: (String title, Status status) {
        setState(() {
          obj.keyResults[krIndex].title = title;
          obj.keyResults[krIndex].status = status;
        });
        _saveObjectivesToPrefs();
      },
    );
  }

  void _deleteKeyResult(Objective obj, int krIndex, int objIndex) {
    setState(() {
      obj.keyResults.removeAt(krIndex);
    });
    _saveObjectivesToPrefs();
  }

  void _addTask(Objective obj, int krIndex, int objIndex) {
    showAddTaskDialog(
      context: context,
      onAdd: (String task) {
        setState(() {
          obj.keyResults[krIndex].tasks.add(task);
        });
        _saveObjectivesToPrefs();
      },
    );
  }

  void _showEditTaskDialog(Objective obj, int krIndex, String task, int objIndex) {
    showEditTaskDialog(
      context: context,
      initialTask: task,
      onSave: (String newTask) {
        setState(() {
          final taskIndex = obj.keyResults[krIndex].tasks.indexOf(task);
          if (taskIndex != -1) {
            obj.keyResults[krIndex].tasks[taskIndex] = newTask;
          }
        });
        _saveObjectivesToPrefs();
      },
    );
  }

  void _deleteTask(Objective obj, int krIndex, String task, int objIndex) {
    setState(() {
      obj.keyResults[krIndex].tasks.remove(task);
    });
    _saveObjectivesToPrefs();
  }

  void _onStatusChange({
    required Status newStatus,
    required void Function() onSetStatus,
  }) {
    setState(() {
      onSetStatus();
    });
    _saveObjectivesToPrefs();
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

    List<Objective> loadedObjectives = [];
    for (final jsonStr in jsonList) {
      final obj = json.decode(jsonStr);
      loadedObjectives.add(
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

    setState(() {
      _objectives
        ..clear()
        ..addAll(loadedObjectives);
    });
  }
}
