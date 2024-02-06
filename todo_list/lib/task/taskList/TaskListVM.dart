import 'package:flutter/material.dart';
import 'package:todo_list/task/taskList/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/taskList/taskFilters/DeadlineTaskSorter.dart';
import 'package:todo_list/task/taskList/taskFilters/TaskFilterBase.dart';
import 'package:todo_list/task/taskList/taskListItem/TaskListHeader.dart';

import 'taskFilters/CompletedTaskFilter.dart';

class TaskListVM extends TaskListVMBase {
  final List<TaskListFilterBase> _filters = [];

  List<TaskListFilterBase> get filters => _filters;

  final bool _incompleteFilterEnable = true;
  final bool _completeFilterEnable = true;

  final bool _groupByDeadline = false;
  final bool _sortByDeadline = true;

  // all/uncategorized tasks

  late final DeadlineTaskSorter _uncategorizedTasks;

  /* List<FilterItem> get listViewItems {
    return [...filters.expand((element) => element.items)];
  }*/
  final List<Widget> _listItems = [];
  final List<TaskModel> _tasks = []; // all tasks in vm

  List<Widget> get listItems => _listItems;

  TaskListVM() {
    if (_incompleteFilterEnable) {
      _filters.add(CompletedTaskFilter(true, this));
    }
    if (_groupByDeadline) {}
    if (_completeFilterEnable) {
      _filters.add(CompletedTaskFilter(false, this));
    }
    _uncategorizedTasks = DeadlineTaskSorter(this, "");
  }

  void sortTasks(List<TaskModel> tasks) {
    for (var task in tasks) {
      sortTask(task);
    }
  }

  void sortTask(TaskModel task) {
    bool filtered = false;
    for (var filter in _filters) {
      if (filter.addTask(task)) {
        filtered = true;
      } else {
        filter.removeTask(task);
      }
    }
    if (!filtered) _uncategorizedTasks.addTask(task);
  }

  @override
  void addTask(TaskModel model) {
    sortTask(model);
    onChange();
  }


  @override
  Future<void> onRefresh() async {
    if (!super.initialized) {
      init(onRefresh);
      return;
    }
    update();
  }

  // Task list implementations

  /// Delete Task
  @override
  void removeTask(TaskModel model) {
    if (!initialized) {
      init(() => removeTask(model));
    }
    if (model.id == null) return;

    resetTask(model);
    onChange();
  }

  @override
  void update() async {
    if (!super.initialized) {
      init(update);
      return;
    }
    reset();

    _tasks.clear();
    super.repository.listTasks().then((tasks) {
      _tasks.addAll(tasks);
      sortTasks(tasks);
      onChange();
    });
  }

  @override
  void onTaskUpdate(TaskModel task) {
    if (!super.initialized) {
      init(() => onTaskUpdate(task));
    }
    sortTask(task);

    onChange();
  }

  void deleteCompletedTasks() {
    List<TaskModel> toRemove = [];
    for (TaskModel task in _tasks) {
      if (task.isComplete) {
        toRemove.add(task);
      }
    }
    for (TaskModel task in toRemove) {
      resetTask(task);
      super.repository.deleteTask(task.id);
    }
    onChange();
  }

  // helper functions

  void reset() {
    // Empty filters and repopulate
    _uncategorizedTasks.clear();
    for (var filter in _filters) {
      filter.clear();
    }
  }

  TaskModel resetTask(TaskModel task) {
    // remove from all filters
    _tasks.remove(task);

    for (var filter in _filters) {
      filter.removeTask(task);
    }
    // create new task from the data in the last task
    TaskModel newInstance = TaskModel(task.getData());
    return newInstance;
  }

  void rebuildFilters() {
    _listItems.clear();
    for (var filter in _filters) {
      List<Widget> items = filter.listForGroupedItems();
      if(items.length > 1) {
        _listItems.addAll(items);
      }
    }
    List<Widget> uncategorizedSection = _uncategorizedTasks.listForSortedItems();
    if(uncategorizedSection.length > 0) {
      _listItems.add(TaskListHeader("Other"));
      _listItems.addAll(uncategorizedSection);
    }
  }

  void sortItems() {}

  void onChange() {
    rebuildFilters();
    notifyListeners();
  }
}
