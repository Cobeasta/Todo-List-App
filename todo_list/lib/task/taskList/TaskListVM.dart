import 'dart:collection';

import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';
import 'package:todo_list/task/taskList/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';

class TaskListVM extends TaskListVMBase {
  bool loading = false;

  static SplayTreeMap<DateTime, Set<TaskModel>> getTaskSet() {
    return SplayTreeMap(compareDates);
  }

  static int compareDates(DateTime key1, DateTime key2) {
    return int.parse("${key1.year}${key1.month}${key1.day}") -
        int.parse("${key2.year}${key2.month}${key2.day}");
  }

  final SplayTreeMap<DateTime, Set<TaskModel>> _taskMap =
      SplayTreeMap(compareDates);

  List<TaskModel> getOverdue() {
    DateTime tod = DateTimeConverter.today();
    int todInt = int.parse("${tod.year}${tod.month}${tod.day}");
    List<TaskModel> tasks = [];
    // add all tasks with due dates before today to return
    tasks.addAll(_taskMap.entries
        .where((element) =>
            int.parse(
                    "${element.key.year}${element.key.month}${element.key.day}") -
                todInt <
            0)
        .expand((element) => element.value)
        .where((element) => !element.isComplete));

    return tasks;
  }

  List<TaskModel> getByDay(DateTime day) {
    // add all tasks with due dates  after today
    List<TaskModel> mapResult = _taskMap.entries
        .where((element) =>
            element.key.year == day.year &&
            element.key.month == day.month &&
            element.key.day == day.day)
        .expand((element) => element.value)
        .toList();
    return mapResult;
  }

  SplayTreeMap<DateTime, Set<TaskModel>> getUpcoming() {
    DateTime now = DateTime.now();
    DateTime tom = DateTime(now.year, now.month, now.day + 1);

    SplayTreeMap<DateTime, Set<TaskModel>> upcoming = getTaskSet();
    // add all tasks with due dates  after today
    _taskMap.entries
        .where((element) => element.key.isAfter(tom))
        .forEach((element) {
      if (upcoming[element.key] == null) {
        upcoming[element.key] = <TaskModel>{};
      }
      upcoming[element.key]!.addAll(element.value.where((e) => !e.isComplete));
    });
    return upcoming;
  }

  Set<TaskModel> getCompleted() {
    Set<TaskModel> completed = <TaskModel>{};
    for (var element in _taskMap.entries) {
      List<TaskModel> compl = element.value.where((e) => e.isComplete).toList();
      completed.addAll(compl);
    }
    return completed;
  }

  @override
  void addTask(TaskModel model) {
    // initialize map list for deadline if null
    if (_taskMap[model.deadline] == null) {
      _taskMap[model.deadline] = <TaskModel>{};
    }
    _taskMap[model.deadline]!.add(model);
    notifyListeners();
  }

  void addTasks(List<TaskModel> models) {
    for (var model in models) {
      if (_taskMap[model.deadline] == null) {
        _taskMap[model.deadline] = <TaskModel>{};
      }
      _taskMap[model.deadline]!.add(model);
    }
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

  void getAllTasks() async {
    if (!super.initialized) {
      init(getAllTasks);
      return;
    }
    loading = true;
    notifyListeners();
    _taskMap.forEach((key, value) => value.clear());
    _taskMap.clear();
    List<TaskModel> tasks = await super.repository.listTasks();
    addTasks(tasks);
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
    if (_taskMap[model.deadline] != null) {
      _taskMap[model.deadline]!
          .removeWhere((element) => element.id == model.id);
    }
  }

  void deleteCompletedTasks() {
    List<TaskModel> toRemove = [];

    _taskMap.forEach((key, value) {
      toRemove.addAll(value.where((element) => element.isComplete));
      value.removeWhere((element) => element.isComplete);
    });
    for (var element in toRemove) {
      repository.deleteTask(element.id);
    }
    notifyListeners();
  }

  SplayTreeMap<DateTime, Set<TaskModel>> getAfter(DateTime start) {
    SplayTreeMap<DateTime, Set<TaskModel>> tasksAfterDate = getTaskSet();
    _taskMap.keys
        .where((element) =>
            element.isAfter(start) || element.isAtSameMomentAs(start))
        .forEach((date) {
      tasksAfterDate[date] = _taskMap[date]!;
    });
    return tasksAfterDate;
  }
}
