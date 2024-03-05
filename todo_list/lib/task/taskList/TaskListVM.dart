import 'dart:collection';

import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';
import 'package:todo_list/task/taskList/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';

enum TaskListModes {
  today(name: "Today"),
  week(name: "Next 7 Days"),
  upcoming(name: "Upcoming");
  const TaskListModes(
  {
    required this.name
});
  final String name;
}

class TaskListVM extends TaskListVMBase {
  // fields for configuration
  bool _loading = false;
  bool _showOverdue = true;
  TaskListModes mode = TaskListModes.today;
  bool _showCompleted = false;

  bool _groupByDate = true;

  DateTime _start = DateTimeConverter.today();
  DateTime? _end = DateTimeConverter.tomorrow();

  // getters for view usage
  bool get loading => _loading;

  bool get showOverdue => _showOverdue;


  bool get showCompleted => _showCompleted;

  // functions used by view

  void configure(
      {bool? showOverdue,
      TaskListModes? mode = TaskListModes.today,
      bool? showCompleted}) {
    _showOverdue = showOverdue ?? _showOverdue;
    _showCompleted = showCompleted ?? _showCompleted;
    if (mode != null) {
      switch (mode) {
        case TaskListModes.today:
          _start = DateTimeConverter.today();
          _end = DateTimeConverter.tomorrow();
          this.mode = mode;
          break;
        case TaskListModes.week:
          _start = DateTimeConverter.today();
          _end = DateTime(_start.year, _start.month, _start.day + 8);
          this.mode = mode;
          break;
        case TaskListModes.upcoming:
          _start = DateTimeConverter.today();
          _end = null;
          this.mode = mode;
          break;
      }
    }
    notifyListeners();
  }

  final List<TaskModel> _tasks = [];

  List<TaskModel> getOverdue() {
    // overdue tasks must not be complete
    return _tasks.where((e) => e.overdue && !e.isComplete).toSet().toList();
  }

  /**
   * Return tasks as specified in listModes _mode field
   */
  SplayTreeMap<DateTime, List<TaskModel>> getTasksMain() {
    return _getTasksGroupedByDate(start: _start, end: _end);
  }

  Set<TaskModel> getCompleted() {
    return _tasks.where((e) => e.isComplete).toSet();
  }

  @override
  void addTask(TaskModel model) {
    // initialize map list for deadline if null
    _tasks.add(model);
    notifyListeners();
  }

  void addTasks(List<TaskModel> models) {
    _tasks.addAll(models);
    // initialize map list for deadline if null
    notifyListeners();
  }

  @override
  Future<void> onRefresh() async {
    if (!super.initialized) {
      init(onRefresh);
      return;
    }
    getAllTasks();
  }

  @override
  void render() {
    notifyListeners();
  }

  void getAllTasks() async {
    if (!super.initialized) {
      init(getAllTasks);
      return;
    }
    _loading = true;
    notifyListeners();
    _tasks.clear();
    List<TaskModel> tasks = await super.repository.listTasks();
    _tasks.addAll(tasks);
    _loading = false;
    notifyListeners();
  }

  // Task list implementations

  /// Delete Task
  @override
  void removeTask(TaskModel model) {
    if (!initialized) {
      init(() => removeTask(model));
    }
    _tasks.removeWhere((element) => element.id == model.id);
  }

  void deleteCompletedTasks() {
    List<TaskModel> toRemove = [];
    toRemove.addAll(_tasks.where((element) => element.isComplete));
    _tasks.removeWhere((element) => toRemove.contains(element));

    for (var element in toRemove) {
      repository.deleteTask(element.id);
    }
    notifyListeners();
  }

  /**
   * Get a SplayTreeMap<DateTime, list<taskModel>
   *   Optional DateTime start  (inclusive)
   *   optional DateTime end  (exclusive)
   *
   * Elements are grouped by date
   */
  SplayTreeMap<DateTime, List<TaskModel>> _getTasksGroupedByDate(
      {bool includeOverdue = false,
      bool includeCompleted = false,
      DateTime? start,
      DateTime? end}) {
    SplayTreeMap<DateTime, List<TaskModel>> groupedTasks =
        SplayTreeMap(compareDates);

    Set<TaskModel> filtered = _tasks.where((e) {
      return ( !e.isComplete && !e.overdue &&
          start != null &&
                  (e.deadline.isAfter(start) ||
                      e.deadline.isAtSameMomentAs(start)) ||
              start == null) &&
          (end != null && (e.deadline.isBefore(end)) || end == null);
    }).toSet();
    for (var element in filtered) {
      DateTime date = DateTime(
          element.deadline.year, element.deadline.month, element.deadline.day);
      if (groupedTasks[date] == null) {
        groupedTasks[date] = [];
      }
      groupedTasks[date]!.add(element);
    }
    return groupedTasks;
  }

  List<TaskModel> getTasksByDay(DateTime day) {
    return _tasks
        .where((element) => compareDates(element.deadline, day) == 0)
        .toList();
  }
}

int compareDates(DateTime key1, DateTime key2) {
  return int.parse("${key1.year}${key1.month}${key1.day}") -
      int.parse("${key2.year}${key2.month}${key2.day}");
}
