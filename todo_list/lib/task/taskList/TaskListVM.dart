import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/Settings.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';
import 'package:todo_list/main.dart';

import 'package:todo_list/task/task_repository.dart';
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
  // Dependencies
  late TaskRepository _repository;
  late Settings _settings;

  final List<TaskModel> _tasks = [];

  //  View state
  bool loading = false;
  bool settingsInitialized = false;
  bool repositoryInitialized = false;

  TaskListModes get mode => _settings.taskListMode; // view mode
  bool get showOverdue =>
      _settings.taskListShowOverdue; // flag for showing overdue
  bool get showCompleted =>
      _settings.taskListShowCompleted; // flag show completed

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

  TaskListVM();

  void init() {
    if (kDebugMode) {
      print("TaskListVM init");
    }
    getIt.getAsync<Settings>().then((value) => initSettings(value));
    getIt.getAsync<TaskRepository>().then((value) => initRepository(value));
  }

  void initSettings(Settings settings) {
    _settings = settings;
    settingsInitialized = true;
    if (kDebugMode) {
      print("TaskListVM Settings initialized");
    }
    notifyListeners();
  }

  void initRepository(TaskRepository repository) {
    _repository = repository;
    repositoryInitialized = true;
    if (kDebugMode) {
      print("TaskListVM repository initialized");
    }
    getAllTasks();
  }

  void configure(
      {bool? showOverdue,
      TaskListModes? mode = TaskListModes.today,
      bool? showCompleted}) {
    if (showOverdue != null) {
      _settings.taskListShowOverdue = showOverdue;
    }
    if (showCompleted != null) {
      _settings.taskListShowCompleted = showCompleted;
    }

    if (mode != null) {
      _settings.taskListMode = mode;
    }
    notifyListeners();
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
    getAllTasks();
  }

  void getAllTasks() async {
    if (kDebugMode) {
      print("TaskListVM getAllTasks");
    }
    loading = true;
    notifyListeners();
    _tasks.clear();
    List<TaskModel> tasks = await _repository.listTasks();
    _tasks.addAll(tasks);
    loading = false;
    if (kDebugMode) {
      print("TaskListVM Received ${tasks.length} Tasks");
    }
    notifyListeners();
  }

// Task list implementations

  void removeTask(TaskModel model) {
    if (kDebugMode) {
      print("TaskListVM removeTask");
    }
    _tasks.removeWhere((element) => element.id == model.id);
  }

  void deleteCompletedTasks() {
    if (kDebugMode) {
      print("TaskListVM deleteCompletedTasks");
    }
    List<TaskModel> toRemove = [];
    toRemove.addAll(_tasks.where((element) => element.isComplete));
    _tasks.removeWhere((element) => toRemove.contains(element));

    for (var element in toRemove) {
      _repository.deleteTask(element.id);
    }
    notifyListeners();
  }

  List<TaskModel> getToday() {
    if (kDebugMode) {
      print("TaskListVM getToday");
    }
    return _tasks
        .where((e) {
          return !e.isComplete &&
              compareDates(e.deadline, DateTimeConverter.today()) == 0;
        })
        .toSet()
        .toList();
  }

  /// Get a SplayTreeMap<DateTime, list<taskModel>
  ///  Overdue and complete tasks are not included in the result
  SplayTreeMap<DateTime, List<TaskModel>> getUpcoming() {
    if (kDebugMode) {
      print("TaskListVM getUpcoming");
    }
    SplayTreeMap<DateTime, List<TaskModel>> groupedTasks =
        SplayTreeMap(compareDates);
    DateTime tod = DateTimeConverter.today();
    // Get and filter tasks
    Set<TaskModel> filtered = _tasks.where((e) {
      return (!e.isComplete &&
          (showOverdue || !e.overdue) &&
          compareDates(e.deadline, tod) > 0 &&
          (endDate != null && (e.deadline.isBefore(endDate!)) ||
              endDate == null));
    }).toSet();

    // Group elements by date
    for (var element in filtered) {
      DateTime day = DateTime(
          element.deadline.year, element.deadline.month, element.deadline.day);
      if (groupedTasks[day] == null) {
        groupedTasks[day] = [];
      }
      groupedTasks[day]!.add(element);
    }
    return groupedTasks;
  }

  List<TaskModel> getOverdue() {
    if (kDebugMode) {
      print("TaskListVM getOverdue");
    }
    return _tasks
        .where((e) =>
            compareDates(e.deadline, DateTimeConverter.today()) < 0 &&
            !e.isComplete)
        .toSet()
        .toList();
  }

  List<TaskModel> getComplete() {
    if (kDebugMode) {
      print("TaskListVM getComplete");
    }
    return _tasks.where((e) => e.isComplete).toSet().toList();
  }

  void onModalClose() {
    notifyListeners();
  }
}
