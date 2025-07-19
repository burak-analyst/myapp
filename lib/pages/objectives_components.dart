import 'package:flutter/material.dart';
import '../models/objective.dart';
import '../models/key_result.dart';

// Filters section widget
Widget buildFiltersWidget({
  required BuildContext context,
  required int selectedYear,
  required void Function(int year) onYearChanged,
  required List<int> yearRange,
  required List<String> periods,
  required int selectedPeriodIndex,
  required void Function(int index) onPeriodChanged,
}) {
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
                  icon: const Icon(Icons.arrow_back, color: Colors.blueGrey),
                  onPressed: () {
                    int newYear = (selectedYear - 1).clamp(yearRange.first, yearRange.last);
                    onYearChanged(newYear);
                  },
                ),
                Text(
                  '$selectedYear',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.blueGrey),
                  onPressed: () {
                    int newYear = (selectedYear + 1).clamp(yearRange.first, yearRange.last);
                    onYearChanged(newYear);
                  },
                ),
              ],
            ),
            DropdownButton<String>(
              value: periods[selectedPeriodIndex],
              items: List.generate(periods.length, (i) {
                return DropdownMenuItem(
                  value: periods[i],
                  child: Text(periods[i], style: const TextStyle(fontSize: 16)),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  onPeriodChanged(periods.indexOf(value));
                }
              },
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ],
    ),
  );
}

// Main body widget
Widget buildObjectivesBody({
  required BuildContext context,
  required Widget Function() buildFilters,
  required List<Objective> filteredObjectives,
  required Widget Function(Objective obj, int index) buildObjectiveCard,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blueGrey[100]!, Colors.white],
      ),
    ),
    child: Column(
      children: [
        buildFilters(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredObjectives.length,
            itemBuilder: (context, index) {
              final obj = filteredObjectives[index];
              return buildObjectiveCard(obj, index);
            },
          ),
        ),
      ],
    ),
  );
}

// Objective Card widget
Widget buildObjectiveCardWidget({
  required BuildContext context,
  required Objective obj,
  required int objIndex,
  required void Function(Objective obj, int objIndex) onEditObjective,
  required void Function(Objective obj, int krIndex, int objIndex) onEditKeyResult,
  required void Function(Objective obj, int objIndex) onAddKeyResult,
  required void Function(Objective obj, int krIndex, String task, int objIndex) onEditTask,
  required void Function(Objective obj, int krIndex, int objIndex) onAddTask,
  required Widget Function(Status status) statusTag,
  required Color Function(Status status) statusColor,
}) {
  return Card(
    elevation: 4,
    margin: const EdgeInsets.only(bottom: 16),
    color: statusColor(obj.status).withOpacity(0.2),
    child: ExpansionTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              obj.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          statusTag(obj.status),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueGrey),
            onPressed: () => onEditObjective(obj, objIndex),
          ),
        ],
      ),
      children: [
        for (int i = 0; i < obj.keyResults.length; i++)
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      obj.keyResults[i].title,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  statusTag(obj.keyResults[i].status),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueGrey),
                    onPressed: () => onEditKeyResult(obj, i, objIndex),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var task in obj.keyResults[i].tasks)
                    Row(
                      children: [
                        Expanded(
                          child: Text('  - $task', style: const TextStyle(fontSize: 14)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueGrey),
                          onPressed: () => onEditTask(obj, i, task, objIndex),
                        ),
                      ],
                    ),
                  TextButton.icon(
                    onPressed: () => onAddTask(obj, i, objIndex),
                    icon: const Icon(Icons.add, color: Colors.blueGrey),
                    label: const Text('add task', style: TextStyle(color: Colors.blueGrey)),
                  ),
                ],
              ),
              trailing: statusTag(obj.keyResults[i].status),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextButton.icon(
            onPressed: () => onAddKeyResult(obj, objIndex),
            icon: const Icon(Icons.add, color: Colors.blueGrey),
            label: const Text('add key result', style: TextStyle(color: Colors.blueGrey)),
          ),
        ),
      ],
    ),
  );
}

// Status tag widget
Widget statusTagWidget(Status status) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: statusTextColorHelper(status),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      status.name.replaceAll('_', ' ').toLowerCase().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}

// Status color helpers
Color statusColorHelper(Status status) {
  switch (status) {
    case Status.notStarted:
      return Colors.blue.shade100;
    case Status.inProgress:
      return Colors.orange.shade100;
    case Status.done:
      return Colors.green.shade300;
  }
}

Color statusTextColorHelper(Status status) {
  switch (status) {
    case Status.notStarted:
      return Colors.blue;
    case Status.inProgress:
      return Colors.orange;
    case Status.done:
      return Colors.green.shade800;
  }
}

// Dialogs for add/edit

void showAddObjectiveDialog({
  required BuildContext context,
  required List<String> categories,
  required String selectedCategory,
  required int selectedYear,
  required int selectedPeriodIndex,
  required void Function(Objective obj) onAdd,
}) {
  final controller = TextEditingController();
  Status selectedStatus = Status.notStarted;
  String selectedCat = selectedCategory;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('new objective', style: TextStyle(fontSize: 20)),
        content: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
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
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.name.replaceAll('_', ' ').toLowerCase().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedStatus = val;
                },
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedCat,
                isExpanded: true,
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCat = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('cancel', style: TextStyle(color: Colors.blueGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              onAdd(
                Objective(
                  title: controller.text,
                  status: selectedStatus,
                  category: selectedCat,
                  year: selectedYear,
                  periodIndex: selectedPeriodIndex,
                  keyResults: [],
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            child: const Text('add', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

void showEditObjectiveDialog({
  required BuildContext context,
  required Objective obj,
  required void Function(String title, Status status) onSave,
}) {
  final controller = TextEditingController(text: obj.title);
  Status selectedStatus = obj.status;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('edit objective', style: TextStyle(fontSize: 20)),
        content: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
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
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.name.replaceAll('_', ' ').toLowerCase().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedStatus = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('cancel', style: TextStyle(color: Colors.blueGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text, selectedStatus);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            child: const Text('save', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

void showAddKeyResultDialog({
  required BuildContext context,
  required void Function(KeyResult kr) onAdd,
}) {
  final controller = TextEditingController();
  Status krStatus = Status.notStarted;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('add key result', style: TextStyle(fontSize: 20)),
        content: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
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
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.name.replaceAll('_', ' ').toLowerCase().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) krStatus = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('cancel', style: TextStyle(color: Colors.blueGrey))),
          ElevatedButton(
            onPressed: () {
              onAdd(KeyResult(title: controller.text, status: krStatus, tasks: []));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            child: const Text('add', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

void showEditKeyResultDialog({
  required BuildContext context,
  required KeyResult keyResult,
  required void Function(String title, Status status) onSave,
}) {
  final controller = TextEditingController(text: keyResult.title);
  Status selectedStatus = keyResult.status;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('edit key result', style: TextStyle(fontSize: 20)),
        content: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
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
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.name.replaceAll('_', ' ').toLowerCase().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) selectedStatus = val;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('cancel', style: TextStyle(color: Colors.blueGrey))),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text, selectedStatus);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            child: const Text('save', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

void showAddTaskDialog({
  required BuildContext context,
  required void Function(String task) onAdd,
}) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('add task', style: TextStyle(fontSize: 20)),
      content: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'task'),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('cancel', style: TextStyle(color: Colors.blueGrey))),
        ElevatedButton(
          onPressed: () {
            onAdd(controller.text);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
          child: const Text('add', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void showEditTaskDialog({
  required BuildContext context,
  required String initialTask,
  required void Function(String newTask) onSave,
}) {
  final controller = TextEditingController(text: initialTask);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('edit task', style: TextStyle(fontSize: 20)),
      content: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'task'),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('cancel', style: TextStyle(color: Colors.blueGrey))),
        ElevatedButton(
          onPressed: () {
            onSave(controller.text);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
          child: const Text('save', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
