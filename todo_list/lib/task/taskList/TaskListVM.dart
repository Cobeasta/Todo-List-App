import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:todo_list/Settings.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/task/TaskRepository.dart';
import 'package:todo_list/task/TaskModel.dart';

/*class Setting<T> {
  final String name;
  T value;
  final T defaultValue;
  Settings settings;

  void init() {

  }
  T get getValue => value;
  Setting(this.name, this.defaultValue, this.value, this.settings);

}*/


enum TaskListModes {
  today(name: "Today", value: 0),
  week(name: "Next 7 Days", value: 1),
  upcoming(name: "Upcoming", value: 2);

  const TaskListModes({required this.name, required this.value});

  final String name;
  final int value;
}

class TaskListVM extends ChangeNotifier {
  final String _screenName;


  // State
  bool _loading = false;
  final List<TaskModel> _tasks = [];
  bool _initialized = false;

  // Configuration

  bool _showOverdue = true;
  TaskListModes mode = TaskListModes.today;
  bool _showCompleted = false;

  DateTime? get endDate {
    DateTime tod = DateTimeConverter.today();
    switch (mode) {
      case TaskListModes.today:
        return DateTimeConverter.tomorrow();
      case TaskListModes.week:
        return DateTime(tod.year, tod.month, tod.day + 8);
      case TaskListModes.upcoming:
        return null;
    }
  }


  // Getters
  bool get loading => _loading;

  bool get showOverdue => _showOverdue;

  bool get showCompleted => _showCompleted;

  // Dependencies
  late TaskRepository _repository;
  late Settings _settings;

  TaskListVM(this._screenName);

  void _initAsync(void Function() callback) async {
    var repoTask = getIt.getAsync<TaskRepository>();
    var settingsTask = getIt.getAsync<Settings>();
    _repository = await repoTask;
    _settings = await settingsTask;
    _initialized = true;
    _getSettings();
    callback();
  }

  void _getSettings() {
    _showOverdue = _settings.taskListShowOverdue;
    mode = _settings.taskListMode;
    _showCompleted = _settings.taskListShowCompleted;
  }

  void configure({bool? showOverdue,
    TaskListModes? mode = TaskListModes.today,
    bool? showCompleted}) {
    if (showOverdue != null) {
      _showOverdue = showOverdue;
      _settings.taskListShowOverdue = _showOverdue;
    }
    if (showCompleted != null) {
      _showCompleted = showCompleted;
      _settings.taskListShowCompleted = _showCompleted;
    }

    if (mode != null) {
      this.mode = mode;
      _settings.taskListMode = mode;
    }
    notifyListeners();
  }




List<TaskModel> getOverdue() {
  // overdue tasks must not be complete
  return _tasks.where((e) => e.overdue && !e.isComplete).toSet().toList();
}

/// Return tasks as specified in listModes _mode field
SplayTreeMap<DateTime, List<TaskModel>> getTasksMain() {
  return _getTasksGroupedByDate(start: DateTimeConverter.today(), end: endDate);
}

Set<TaskModel> getCompleted() {
  return _tasks.where((e) => e.isComplete).toSet();
}

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

void updateTask(TaskModel model) async {
  await _repository.updateTask(model);
  notifyListeners();
}

Future<void> onRefresh() async {
  if (!_initialized) {
    _initAsync(onRefresh);
    return;
  }
  getAllTasks();
}

void getAllTasks() async {
  if (!_initialized) {
    _initAsync(getAllTasks);
    return;
  }
  _loading = true;
  notifyListeners();
  _tasks.clear();
  List<TaskModel> tasks = await _repository.listTasks();
  _tasks.addAll(tasks);
  _loading = false;
  notifyListeners();
}

// Task list implementations

void removeTask(TaskModel model) {
  if (!_initialized) {
    _initAsync(() => removeTask(model));
  }
  _tasks.removeWhere((element) => element.id == model.id);
}

void deleteCompletedTasks() {
  List<TaskModel> toRemove = [];
  toRemove.addAll(_tasks.where((element) => element.isComplete));
  _tasks.removeWhere((element) => toRemove.contains(element));

  for (var element in toRemove) {
    _repository.deleteTask(element.id);
  }
  notifyListeners();
}

/// Get a SplayTreeMap<DateTime, list<taskModel>
///   Optional DateTime start  (inclusive)
///   optional DateTime end  (exclusive)
///
/// Elements are grouped by date
SplayTreeMap<DateTime, List<TaskModel>> _getTasksGroupedByDate(
    {DateTime? start, DateTime? end}) {
  SplayTreeMap<DateTime, List<TaskModel>> groupedTasks =
  SplayTreeMap(compareDates);

  Set<TaskModel> filtered = _tasks.where((e) {
    return (!e.isComplete &&
        !e.overdue &&
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

void onModalClose() {
  notifyListeners();
}}

int compareDates(DateTime key1, DateTime key2) {
  return int.parse("${key1.year}${key1.month}${key1.day}") -
      int.parse("${key2.year}${key2.month}${key2.day}");
}
