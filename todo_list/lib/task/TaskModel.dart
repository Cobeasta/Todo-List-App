import 'package:todo_list/database/tables/task.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';

class TaskModel {
  TaskModel(Task task)
      : _id = task.id,
        _title = task.title,
        _description = task.description,
        _deadline = task.deadline,
        _completedDate = task.completedDate;

  TaskModel.createEmpty()
      : _id = null,
        _title = "",
        _description = "",
        _deadline = DateTimeConverter.today(),
        _completedDate = null;

  final int? _id;
  String _title;
  String _description;
  DateTime? _completedDate;
  DateTime _deadline;

  String get title => _title;

  String get description => _description;

  DateTime? get completedDate => _completedDate;

  bool get isComplete => _completedDate != null;

  bool get overdue =>
      _deadline.isBefore(DateTimeConverter.today()) && !isComplete;

  DateTime get deadline => _deadline;

  get id => _id;

  void updateTitle(String text) {
    _title = text;
  }

  void updateDescription(String text) {
    _description = text;
  }

  void updateDeadline(DateTime dateTime) {
    _deadline = dateTime;
  }

  /// Change value of isComplete.
  void setComplete(bool? value) {
    if (value == null && _completedDate == null) {
      // completion not specified, task not complete
      _completedDate = DateTimeConverter.today();
    } else if (value == null && _completedDate != null) {
      // completion not specified, task incomplete
      _completedDate = null;
    } else if (value != null && _completedDate == null) {
      // completion specified, task not complete
      _completedDate = (value == false) ? null : DateTime.timestamp();
    } else {
      // Task already complete, if still complete, no change
      _completedDate = (value == false) ? null : _completedDate;
    }
    // _isCompleted did change
  }

  @override
  bool operator ==(Object other) {
    if (other is TaskModel) {
        return _id == other.id;
    }
    return false;
  }

  @override
  int get hashCode => _id.hashCode;
}
