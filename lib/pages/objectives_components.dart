import 'package:flutter/material.dart';
import '../models/objective.dart';
import '../models/key_result.dart';

// ----------- FILTERS ------------

Widget buildFiltersWidget({
  required BuildContext context,
  required int selectedYear,
  required void Function(int year) onYearChanged,
  required List<int> yearRange,
  required List<String> periods,
  required int selectedPeriodIndex,
  required void Function(int index) onPeriodChanged,
  required List<String> categories,
  required String selectedCategory,
  required void Function(String cat) onCategoryChanged,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
      boxShadow: [
        BoxShadow(
          color: Colors.blueGrey.withOpacity(0.07),
          offset: const Offset(0, 5),
          blurRadius: 16,
        ),
      ],
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 10,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueGrey),
              onPressed: () {
                int newYear = (selectedYear - 1).clamp(yearRange.first, yearRange.last);
                onYearChanged(newYear);
              },
            ),
            Text(
              '$selectedYear',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueGrey,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.blueGrey),
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
              child: Text(periods[i], style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500)),
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
        DropdownButton<String>(
          value: selectedCategory,
          items: categories.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(
                cat,
                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onCategoryChanged(value);
            }
          },
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    ),
  );
}

// ----------- OBJECTIVE CARD ------------

Widget buildObjectiveCardWidget({
  required BuildContext context,
  required Objective obj,
  required int objIndex,
  required void Function(Objective obj, int objIndex) onEditObjective,
  required void Function(int objIndex) onDeleteObjective,
  required void Function(Objective obj, int krIndex, int objIndex) onEditKeyResult,
  required void Function(Objective obj, int krIndex, int objIndex) onDeleteKeyResult,
  required void Function(Objective obj, int objIndex) onAddKeyResult,
  required void Function(Objective obj, int krIndex, String task, int objIndex) onEditTask,
  required void Function(Objective obj, int krIndex, String task, int objIndex) onDeleteTask,
  required void Function(Objective obj, int krIndex, int objIndex) onAddTask,
  required void Function({required Status newStatus, required void Function() onSetStatus}) onStatusChange,
}) {
  return Card(
    elevation: 6,
    margin: const EdgeInsets.only(bottom: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: statusCardColor(obj.status),
    child: Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 2),
      child: ExpansionTile(
        iconColor: Colors.blueGrey[900],
        collapsedIconColor: Colors.blueGrey[400],
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(
              Icons.flag,
              color: statusColor(obj.status),
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                obj.title,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            statusTagWidget(obj.status),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 22),
              tooltip: "Edit Objective",
              onPressed: () => onEditObjective(obj, objIndex),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
              tooltip: "Delete Objective",
              onPressed: () => _confirmDelete(context, "Delete this objective?", () => onDeleteObjective(objIndex)),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: _buildStatusSelector(
              context,
              obj.status,
              (newStatus) => onStatusChange(
                newStatus: newStatus,
                onSetStatus: () => obj.status = newStatus,
              ),
            ),
          ),
          const Divider(thickness: 1, color: Color(0xFFE2E7ED)),
          ...List.generate(obj.keyResults.length, (i) {
            return _buildKeyResultCard(
              context: context,
              kr: obj.keyResults[i],
              krIndex: i,
              obj: obj,
              objIndex: objIndex,
              onEditKeyResult: onEditKeyResult,
              onDeleteKeyResult: onDeleteKeyResult,
              onEditTask: onEditTask,
              onDeleteTask: onDeleteTask,
              onAddTask: onAddTask,
              onStatusChange: onStatusChange,
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blueGrey[700]!),
                backgroundColor: Colors.blueGrey[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => onAddKeyResult(obj, objIndex),
              icon: const Icon(Icons.add, color: Colors.blueGrey),
              label: const Text(
                'Add Key Result',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildKeyResultCard({
  required BuildContext context,
  required KeyResult kr,
  required int krIndex,
  required Objective obj,
  required int objIndex,
  required void Function(Objective obj, int krIndex, int objIndex) onEditKeyResult,
  required void Function(Objective obj, int krIndex, int objIndex) onDeleteKeyResult,
  required void Function(Objective obj, int krIndex, String task, int objIndex) onEditTask,
  required void Function(Objective obj, int krIndex, String task, int objIndex) onDeleteTask,
  required void Function(Objective obj, int krIndex, int objIndex) onAddTask,
  required void Function({required Status newStatus, required void Function() onSetStatus}) onStatusChange,
}) {
  return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
    color: statusCardColor(kr.status).withOpacity(0.95),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.check_circle_rounded, color: statusColor(kr.status), size: 26),
            title: Text(
              kr.title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _buildStatusSelector(
                context,
                kr.status,
                (newStatus) => onStatusChange(
                  newStatus: newStatus,
                  onSetStatus: () => kr.status = newStatus,
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                  tooltip: "Edit Key Result",
                  onPressed: () => onEditKeyResult(obj, krIndex, objIndex),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  tooltip: "Delete Key Result",
                  onPressed: () => _confirmDelete(context, "Delete this key result?", () => onDeleteKeyResult(obj, krIndex, objIndex)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(kr.tasks.length, (j) {
                  final task = kr.tasks[j];
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      leading: const Icon(Icons.radio_button_checked, size: 18, color: Colors.blueGrey),
                      title: Text(
                        task,
                        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14),
                      ),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 17, color: Colors.blueGrey),
                            tooltip: "Edit Task",
                            onPressed: () => onEditTask(obj, krIndex, task, objIndex),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 17, color: Colors.redAccent),
                            tooltip: "Delete Task",
                            onPressed: () => _confirmDelete(context, "Delete this task?", () => onDeleteTask(obj, krIndex, task, objIndex)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 2),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[50],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => onAddTask(obj, krIndex, objIndex),
                    icon: const Icon(Icons.add, size: 18, color: Colors.blueGrey),
                    label: const Text(
                      'Add Task',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ----------- STATUS TAG & COLORS ------------

Widget statusTagWidget(Status status) {
  return Container(
    margin: const EdgeInsets.only(left: 7),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: statusColor(status),
      borderRadius: BorderRadius.circular(13),
      boxShadow: [
        BoxShadow(
          color: statusColor(status).withOpacity(0.19),
          blurRadius: 5,
          offset: const Offset(1, 2),
        )
      ],
    ),
    child: Text(
      statusDisplayName(status),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12.5,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Color statusColor(Status status) {
  switch (status) {
    case Status.notStarted:
      return Colors.blueGrey.shade400;
    case Status.inProgress:
      return Colors.orange.shade600;
    case Status.done:
      return Colors.green.shade700;
  }
}

Color statusCardColor(Status status) {
  switch (status) {
    case Status.notStarted:
      return Colors.blueGrey.shade50;
    case Status.inProgress:
      return Colors.orange.shade50;
    case Status.done:
      return Colors.green.shade50;
  }
}

String statusDisplayName(Status status) {
  switch (status) {
    case Status.notStarted:
      return "Not Started";
    case Status.inProgress:
      return "In Progress";
    case Status.done:
      return "Done";
  }
}

// ----------- STATUS SELECTOR ------------

Widget _buildStatusSelector(
    BuildContext context, Status selected, void Function(Status) onChanged) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: Status.values.map((status) {
      final bool isActive = status == selected;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.5),
        child: ChoiceChip(
          label: Text(
            statusDisplayName(status),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.blueGrey[600],
              fontSize: 12,
            ),
          ),
          selected: isActive,
          onSelected: (_) => onChanged(status),
          backgroundColor: statusColor(status).withOpacity(0.16),
          selectedColor: statusColor(status),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }).toList(),
  );
}

// ----------- BEAUTIFUL DIALOG ------------

Widget _beautifulDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required List<Widget> actions,
}) {
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        letterSpacing: 0.8,
        color: Colors.blueGrey,
      ),
    ),
    content: content,
    actions: actions,
  );
}

// ----------- DIALOGS ------------

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
      return _beautifulDialog(
        context: context,
        title: "New Objective",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Objective title'),
            ),
            const SizedBox(height: 16),
            _buildStatusSelector(context, selectedStatus, (s) => selectedStatus = s),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.blueGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              onAdd(
                Objective(
                  title: controller.text.trim(),
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
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}

void showEditObjectiveDialog({
  required BuildContext context,
  required Objective obj,
  required List<String> categories,
  required void Function(String title, Status status, String category) onSave,
}) {
  final controller = TextEditingController(text: obj.title);
  Status selectedStatus = obj.status;
  String selectedCat = obj.category;

  showDialog(
    context: context,
    builder: (context) {
      return _beautifulDialog(
        context: context,
        title: "Edit Objective",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Objective title'),
            ),
            const SizedBox(height: 16),
            _buildStatusSelector(context, selectedStatus, (s) => selectedStatus = s),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.blueGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              onSave(controller.text.trim(), selectedStatus, selectedCat);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
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
      return _beautifulDialog(
        context: context,
        title: "Add Key Result",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Key result title'),
            ),
            const SizedBox(height: 16),
            _buildStatusSelector(context, krStatus, (s) => krStatus = s),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.blueGrey))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              onAdd(KeyResult(title: controller.text.trim(), status: krStatus, tasks: []));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
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
      return _beautifulDialog(
        context: context,
        title: "Edit Key Result",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Key result title'),
            ),
            const SizedBox(height: 16),
            _buildStatusSelector(context, selectedStatus, (s) => selectedStatus = s),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.blueGrey))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              onSave(controller.text.trim(), selectedStatus);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
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
    builder: (context) => _beautifulDialog(
      context: context,
      title: "Add Task",
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Task'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.blueGrey))),
        ElevatedButton(
          onPressed: () {
            if (controller.text.trim().isEmpty) return;
            onAdd(controller.text.trim());
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
          child: const Text('Add', style: TextStyle(color: Colors.white)),
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
    builder: (context) => _beautifulDialog(
      context: context,
      title: "Edit Task",
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Task'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.blueGrey))),
        ElevatedButton(
          onPressed: () {
            if (controller.text.trim().isEmpty) return;
            onSave(controller.text.trim());
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

// ----------- CONFIRM DELETE DIALOG -----------

void _confirmDelete(BuildContext context, String title, void Function() onDelete) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.delete, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.blueGrey)),
        ),
        ElevatedButton(
          onPressed: () {
            onDelete();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
