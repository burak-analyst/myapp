import 'package:flutter/material.dart';
import '../models/objective.dart';
import '../models/key_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
  int _selectedPeriodIndex = 3; // Default to Jul-Aug

  List<Objective> _objectives = [];

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  void _initLoad() async {
    await _loadObjectivesFromPrefs();
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
      _objectives = loadedObjectives;
    });
  }

  List<Objective> get _filteredObjectives => _objectives.where((obj) =>
    obj.year == _selectedYear &&
    obj.periodIndex == _selectedPeriodIndex
  ).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPeriodFilter(),
          const SizedBox(height: 10),
          const Text(
            'Objectives Status by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._categories.map((cat) {
            final catObjs = _filteredObjectives.where((o) => o.category == cat).toList();
            return _categoryRow(cat, objectives: catObjs);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueGrey),
            onPressed: () {
              setState(() {
                _selectedYear = (_selectedYear - 1).clamp(_selectedYear - 3, _selectedYear + 3);
              });
            },
          ),
          Text(
            '$_selectedYear',
            style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.blueGrey),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.blueGrey),
            onPressed: () {
              setState(() {
                _selectedYear = (_selectedYear + 1).clamp(_selectedYear - 3, _selectedYear + 3);
              });
            },
          ),
          const SizedBox(width: 20),
          DropdownButton<String>(
            value: _periods[_selectedPeriodIndex],
            items: List.generate(_periods.length, (i) {
              return DropdownMenuItem(
                value: _periods[i],
                child: Text(_periods[i],
                    style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500)),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPeriodIndex = _periods.indexOf(value);
                });
              }
            },
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(String title, {required List<Objective> objectives}) {
    final done = objectives.where((o) => o.status == Status.done).length;
    final inProgress = objectives.where((o) => o.status == Status.inProgress).length;
    final notStarted = objectives.where((o) => o.status == Status.notStarted).length;
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
