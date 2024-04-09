import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/settings.dart';
import 'package:todo_list/date_utils.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/task/taskList/task_list_model.dart';

import 'package:todo_list/task/task_repository.dart';
import 'package:todo_list/task/task_model.dart';

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
  late Settings _settings;
  late TaskListModel _taskListModel;

  // private fields
  bool _settingsInit = false;

  //  View state
  bool loading = false; // Data unavailable yet
  bool get settingsInitialized => _settingsInit; // settings initialized
  bool get repositoryInitialized => _taskListModel.repositoryInit; // repository initialized
  TaskListModes get mode => _settings.taskListMode; // view mode
  bool get showOverdue =>
      _settings.taskListShowOverdue; // flag for showing overdue
  bool get showCompleted =>
      _settings.taskListShowCompleted; // flag show completed


  /// Start initialization of taskListVM
  void init() {
    if (kDebugMode) {
      print("TaskListVM init");
    }
    getIt.getAsync<Settings>().then((settings) {
      _settings = settings;
      _settingsInit = true;

      if (kDebugMode) {
        print("TaskListVM Settings initialized");
      }
      notifyListeners();
    });

    _taskListModel = TaskListModel(this);
    _taskListModel.init();
  }


  // Overflow menu actions
  selectViewMode(TaskListModes mode) {
    _settings.taskListMode = mode;
    notifyListeners();
  }

  toggleShowOverdue(bool showOverdue) {
    _settings.toggleShowOverdue(showOverdue);
    notifyListeners();
  }

  toggleShowCompleted(bool showCompleted) {
    _settings.toggleShowComplete(showCompleted);
  }



  // EditTaskModal actions
  void editTaskModalSubmit(TaskModel model) {
    // initialize map list for deadline if null
    _taskListModel.addTask(model);
    notifyListeners();
  }
  void removeTask(TaskModel model) {
    if (kDebugMode) {
      print("TaskListVM removeTask");
    }
    _taskListModel.removeTask(model);
  }
  void removeAllCompleted() {
    if (kDebugMode) {
      print("TaskListVM deleteCompletedTasks");
    }
    List<TaskModel> toRemove = [];
    toRemove.addAll(_taskListModel.tasks.where((element) => element.isComplete));

    _taskListModel.removeAll(toRemove);
    notifyListeners();
  }
  void updateTask(TaskModel model) async {
    _taskListModel.updateTask(model);
    notifyListeners();
  }


  // ListView actions
  Future<void> onRefresh() async {
    _taskListModel.queryAllTasks().then((value) => notifyListeners());
  }

// Task list implementations







  Set<TaskModel> get overdue {
    if (kDebugMode) {
      print("TaskListVM getOverdue");
    }

    Set<TaskModel> overdueTasks = _taskListModel.tasks.where((e) => e.overdue).toSet();
    return overdueTasks;
  }




  // Parse Task model state

  Set<TaskModel> get tasksOverdue {
    if (kDebugMode) {
      print("TaskListModel overdue");
    }
    SplayTreeSet<TaskModel> tasks = SplayTreeSet((key1, key2) {
      return key1.deadline.millisecondsSinceEpoch -
          key2.deadline.millisecondsSinceEpoch;
    });
    tasks.addAll(_taskListModel.tasks.where((e) => e.overdue));
    return tasks;
  }

  Set<TaskModel> get tasksDueToday {
    if (kDebugMode) {
      print("TaskListVM getToday");
    }
    return _taskListModel.tasks.where((e) => e.dueToday)
        .toSet();
  }

  Map<DateTime, List<TaskModel>> get tasksUpcoming {
    if (kDebugMode) {
      print("TaskListVM getUpcoming");
    }
    switch (mode) {
      case TaskListModes.today:
        return <DateTime, List<TaskModel>>{};
      case TaskListModes.week:
        return _taskListModel.upcomingTasksByDate(
            TaskListDateUtils.tomorrow(), TaskListDateUtils.daysFromToday(8));
      case TaskListModes.upcoming:
        return _taskListModel.upcomingTasksByDate(TaskListDateUtils.tomorrow(), null);
    }
  }

  Set<TaskModel> get tasksCompleted {
    if (kDebugMode) {
      print("TaskListModel overdue");
    }

    Set<TaskModel> completedTasks = _taskListModel.tasks.where((e) => e.isComplete).toSet();
    return completedTasks;
  }


  void onModalClose() {
    notifyListeners();
  }


  /**
   * Used during initialization of model
   */
  void updateModelState() {
    notifyListeners();
  }

  void dataUpdate() {
    notifyListeners();
  }


}
