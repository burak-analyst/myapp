import 'key_result.dart';

enum Status { notStarted, inProgress, done }

class Objective {
  String title;
  Status status;
  String category;
  int year;
  int periodIndex;
  List<KeyResult> keyResults;

  Objective({
    required this.title,
    required this.status,
    required this.category,
    required this.year,
    required this.periodIndex,
    required this.keyResults,
  });
}
