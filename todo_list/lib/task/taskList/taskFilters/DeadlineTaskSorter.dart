

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/taskList/taskFilters/TaskFilterBase.dart';
import 'package:todo_list/task/taskList/taskListItem/TaskListHeader.dart';
import 'package:todo_list/task/taskList/taskListItem/TaskListItem.dart';

class DeadlineTaskSorter extends TaskListFilterBase {
  final SplayTreeMap<DateTime, List<TaskModel>> _tasks =
      SplayTreeMap(compareTimes);

  DeadlineTaskSorter(super.vm, super.filterName);


  @override
  bool addTask(TaskModel task) {
    if (_tasks[task.deadline] == null) {
      _tasks[task.deadline] = [];
    }
    // insert task to list if not already there
    if (!_tasks[task.deadline]!.contains(task)) {
      _tasks[task.deadline]!.add(task);
      return true;
    }
    return false;
  }

  void addTasks(List<TaskModel> tasks) {
    for (var task in tasks) {
      addTask(task);
    }
  }

  @override
  void removeTask(TaskModel task) {
    if (_tasks[task.deadline] != null) {
      _tasks[task.deadline]!.remove(task);
    }
  }

  @override
  void clear() {
    _tasks.clear();
  }

  static int compareTimes(DateTime d1, DateTime d2) {
    return hashDate(d1) - hashDate(d2);
  }

  static int hashDate(DateTime date) {
    return date.year * 10000 + date.month * 100 + date.day;
  }


  /// Use for group by date
  @override
  List<Widget> listForGroupedItems() {
    List<Widget> result = [];

    _tasks.forEach((key, value) {
      String month = DateFormat.MMM().format(key);
      String day = DateFormat.d().format(key);
      DateTime today = DateTimeConverter.today();
      int comparison = compareTimes(key, today);
      if (comparison < 0) {
        result.add(TaskListHeader("Overdue"));
      } else if (comparison == 0) {
        result.add(TaskListHeader("Today"));
      } else if (key.year == today.year &&
          key.month == today.month &&
          key.day == today.day) {
        result.add(TaskListHeader("Tomorrow"));
      } else {
        String weekday = DateFormat.EEEE().format(key);
        result.add(TaskListHeader("$month $day \u2B24 $weekday"));
      }
      for (TaskModel model in value) {
        result.add(TaskListItemWidget(model, super.vm));
      }
    });
    return result;
  }

  static const MS_PER_6DAYS = (6 * 24 * 60 * 60 * 1000);

  @override
  List<Widget> listForSortedItems() {
    List<Widget> result = [];
    _tasks.forEach((key, value) {
      result.addAll(value.map((e) => TaskListItemWidget(e, super.vm)));
    });
    return result;
  }
}

class TaskDate {}

class TaskDateHeader {}
// 2024-03-15 => 20240315
