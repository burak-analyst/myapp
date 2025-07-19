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
  int _selectedPeriodIndex = 3;
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
      appBar: AppBar(
        title: const Text(
          'Objectives',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: buildObjectivesBody(
        context: context,
        buildFilters: _buildFilters,
        filteredObjectives: _filteredObjectives,
        buildObjectiveCard: _buildObjectiveCard,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddObjectiveDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Objective', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[700],
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

  Widget _buildObjectiveCard(Objective obj, int objIndex) {
    return buildObjectiveCardWidget(
      context: context,
      obj: obj,
      objIndex: objIndex,
      onEditObjective: _showEditObjectiveDialog,
      onEditKeyResult: _showEditKeyResultDialog,
      onAddKeyResult: _addKeyResult,
      onEditTask: _showEditTaskDialog,
      onAddTask: _addTask,
      statusTag: _statusTag,
      statusColor: _statusColor,
    );
  }

  void _showAddObjectiveDialog() {
    showAddObjectiveDialog(
      context: context,
      categories: _categories,
      selectedCategory: _selectedCategory,
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
      onSave: (String title, Status status) {
        setState(() {
          _objectives[objIndex].title = title;
          _objectives[objIndex].status = status;
        });
        _saveObjectivesToPrefs();
      },
    );
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
    return statusTagWidget(status);
  }

  Color _statusColor(Status status) {
    return statusColorHelper(status);
  }
}
