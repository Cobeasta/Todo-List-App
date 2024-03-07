import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:todo_list/Settings.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';
import 'package:todo_list/main.dart';
import 'package:injectable/injectable.dart';

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

@injectable
class TaskListVM extends ChangeNotifier {

  // State
  bool _loading = false;
  final List<TaskModel> _tasks = [];

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
   final TaskRepository _repository;
   final Settings _settings;

  TaskListVM(this._repository, this._settings);

  void _initAsync(void Function() callback) async {
    _getSettings();
    callback();
  }

  void _getSettings() {
    _showOverdue = _settings.taskListShowOverdue;
    mode = _settings.taskListMode;
    _showCompleted = _settings.taskListShowCompleted;
  }

  void configure(
      {bool? showOverdue,
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

  List<TaskModel> getToday() {
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
    SplayTreeMap<DateTime, List<TaskModel>> groupedTasks =
        SplayTreeMap(compareDates);
    DateTime tod = DateTimeConverter.today();
    // Get and filter tasks
    Set<TaskModel> filtered = _tasks.where((e) {
      return (!e.isComplete &&
          (_showOverdue || !e.overdue) &&
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
    return _tasks
        .where((e) =>
            compareDates(e.deadline, DateTimeConverter.today()) < 0 &&
            !e.isComplete)
        .toSet()
        .toList();
  }

  List<TaskModel> getComplete() {
    return _tasks.where((e) => e.isComplete).toSet().toList();
  }

  void onModalClose() {
    notifyListeners();
  }
}
