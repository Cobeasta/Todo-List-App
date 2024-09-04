import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:todo_list/settings.dart';
import 'package:todo_list/date_utils.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/task/taskList/task_list_vm.dart';
import 'package:todo_list/task/task_model.dart';
import 'package:todo_list/task/task_repository.dart';

class TaskListModel {
  TaskListModel(this._vm);

  // dependencies
  final TaskListVM _vm;
  late TaskRepository _repository;
  late Settings _settings;

  void init() {
    getIt.getAsync<TaskRepository>().then((repository) {
      _repository = repository;
      repositoryInit = true;
      if (kDebugMode) {
        print("TaskListVM repository initialized");
      }
      _vm.updateModelState();

      queryAllTasks();
    });
  }

  // private fields
  final List<TaskModel> _tasks = [];

  // Getting model state
  bool repositoryInit = false;

  Future<void> queryAllTasks() async {
    if (kDebugMode) {
      print("TaskListModel getAllTasks");
    }
    _tasks.clear();
    List<TaskModel> tasks = await _repository.listTasks();

    _tasks.addAll(tasks);
    _vm.updateModelState();
  }

  SplayTreeMap<DateTime, List<TaskModel>> upcomingTasksByDate(
      DateTime start, DateTime? end) {
    if (kDebugMode) {
      print("TaskListModel upcomingGroupedByDate");
    }
    // map for output
    SplayTreeMap<DateTime, List<TaskModel>> result =
        SplayTreeMap(TaskListDateUtils.compareDates);

    // get relevant tasks
    Iterable<TaskModel> filtered = _tasks.where((e) {
      return !e.isComplete &&
          !e.overdue &&
          TaskListDateUtils.compareDates(e.deadline, start) >= 0 &&
          (end == null || TaskListDateUtils.compareDates(e.deadline, end) < 0);
    });

    // initialize days if given a specific interval
    if (end != null) {
      DateTime day = start;
      while (!day.isAfter(end)) {
        result[day] = [];
        day = DateTime(day.year, day.month, day.day + 1);
      }
    }
    // Group elements by date
    for (var element in filtered) {
      DateTime day = DateTime(
          element.deadline.year, element.deadline.month, element.deadline.day);
      if (result[day] == null) {
        result[day] = [];
      }
      result[day]!.add(element);
    }
    return result;
  }

  TaskListModes get mode => _settings.taskListMode;

  List<TaskModel> get tasks => _tasks;

  // Setting model state

  Future<void> addTask(TaskModel model) async {
    await _repository.insertTask(model);
    _tasks.add(model);

  }

  Future<void> removeTask(TaskModel model) async {
    _tasks.removeWhere((e) => e == model);
    if (model.id != null) {
      await _repository.deleteTask(model.id!);
    }
  }

  Future<void> removeAll(Iterable<TaskModel> toRemove) async {
    List<int> ids = [];
    for (var element in toRemove) {
      if(element.id != null) {
        _repository.deleteTask(element.id!);
        ids.add(element.id!);
      }

    }
    _tasks.removeWhere((element) => ids.contains(element.id));
  }

  Future<void> updateTask(TaskModel model) async {
    await _repository.updateTask(model);
  }
}
