import 'dart:collection';

import 'package:todo_list/task/taskList/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';

class TaskListVM extends TaskListVMBase {

  bool loading = false;
  bool _showCompleted = false;
  final List<TaskModel> _tasks = [];

  set setShowCompleted(bool val) {
    _showCompleted = val;
    notifyListeners();
  }
  bool get  showCompleted  => _showCompleted;

  List<TaskModel> getOverdue() {
    // overdue tasks must not be complete
    return _tasks.where((e) => e.overdue && !e.isComplete).toSet().toList();
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
    loading = true;
    notifyListeners();
    _tasks.clear();
    List<TaskModel> tasks = await super.repository.listTasks();
    _tasks.addAll(tasks);
    loading = false;
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

  SplayTreeMap<DateTime, List<TaskModel>> getTasksGroupedByDate(
      {bool includeOverdue = false,
      bool includeCompleted = false,
      DateTime? start}) {
    SplayTreeMap<DateTime, List<TaskModel>> groupedTasks =
        SplayTreeMap(compareDates);

    Set<TaskModel> filtered = _tasks.where((e) {
      return (!e.overdue || includeOverdue) &&
          (!e.isComplete || includeCompleted) &&
          (start != null && e.deadline.isAfter(start) || start == null);
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
