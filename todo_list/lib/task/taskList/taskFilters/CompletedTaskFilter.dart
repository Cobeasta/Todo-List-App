import 'package:flutter/material.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/taskList/taskFilters/DeadlineTaskSorter.dart';
import 'package:todo_list/task/taskList/taskListItem/TaskListHeader.dart';

import 'package:todo_list/task/taskList/taskListItem/TaskListItem.dart';

import 'TaskFilterBase.dart';

class CompletedTaskFilter extends TaskListFilterBase {
  final bool _reversed;
  final List<TaskModel> _filteredTasks = [];
  final DeadlineTaskSorter _deadlineTaskSorter;
  final bool _sortByDeadline = true;

  get itemCount => _filteredTasks.length;

  @override
  List<Widget> listForGroupedItems() {
    if (_sortByDeadline) {
      return [
        TaskListHeader(super.filterName),
        ..._deadlineTaskSorter.listForSortedItems()
      ];
    }
    return [
      TaskListHeader(super.filterName),
      ..._filteredTasks.map((e) => TaskListItemWidget(e, super.vm))
    ];
  }

  get filteredTasks => _filteredTasks;

  CompletedTaskFilter(this._reversed, vm)
      : _deadlineTaskSorter =
            DeadlineTaskSorter(vm, _reversed ? "Incomplete" : "Complete"),
        super(vm, _reversed ? "Incomplete" : "Complete");

  bool match(TaskModel model) {
    return (model.completedDate != null) ^ _reversed;
  }

  @override
  void clear() {
    _filteredTasks.clear();
    if (_sortByDeadline) {
      _deadlineTaskSorter.clear();
    }
  }

  @override
  void removeTask(TaskModel model) {
    if (_sortByDeadline) {
      _deadlineTaskSorter.removeTask(model);
    }
    _filteredTasks.remove(model);
  }

  @override
  bool addTask(TaskModel model) {
    if (match(model) && _sortByDeadline) {
      return _deadlineTaskSorter.addTask(model);
    }
    if (match(model) && !_filteredTasks.contains(model)) {
      _filteredTasks.add(model);
      return true;
    } else if (_filteredTasks.contains(model)) {
      return true;
    }
    return false;
  }

  @override
  List<Widget> listForSortedItems() {
    return [..._filteredTasks.map((e) => TaskListItemWidget(e, super.vm))];
  }
}
