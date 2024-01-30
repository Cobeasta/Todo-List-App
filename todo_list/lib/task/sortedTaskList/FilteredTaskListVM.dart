import 'package:flutter/cupertino.dart';
import 'package:todo_list/task/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/sortedTaskList/taskFilters/TaskFilterBase.dart';

import 'taskFilters/CompletedTaskFilter.dart';

class FilteredTaskListVM extends TaskListVMBase {
  final List<TaskListFilterBase> _filters = [];

  List<TaskListFilterBase> get filters => _filters;

  // fields for incomplete filter

  final bool _incompleteFilterEnable = true;

  // fields for complete filter

  final bool _completeFilterEnable = true;

  // all/uncategorized tasks

  final List<TaskModel> _uncategorizedTasks = [];

  /* List<FilterItem> get listViewItems {
    return [...filters.expand((element) => element.items)];
  }*/
  final List<FilterItem> _listItems = [];

  List<FilterItem> get listItems => _listItems;

  FilteredTaskListVM() {
    if (_incompleteFilterEnable) {
      _filters.add(CompletedTaskFilter(true, this));
    }
    if (_completeFilterEnable) {
      _filters.add(CompletedTaskFilter(false, this));
    }
  }

  void sortTasks(List<TaskModel> tasks) {
    for (var task in tasks) {
      sortTask(task);
    }
  }

  void sortTask(TaskModel task) {
    bool filtered = false;
    for (var filter in _filters) {
      if (filter.match(task)) {
        filter.addTask(task);
        filtered = true;
      } else {
        filter.removeTask(task);
      }
    }
    if (!filtered) _uncategorizedTasks.add(task);
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

  /**
   * Delete Task
   */
  @override
  void removeTask(TaskModel model) {
    if (!initialized) {
      init(() => removeTask(model));
    }
    if (model.id == null) return;

    TaskModel newInstance = resetTask(model);
    onChange();
  }

  @override
  void update() async {
    if (!super.initialized) {
      init(update);
      return;
    }
    reset();

    super.repository.listTasks().then((tasks) {
      sortTasks(tasks);
      onChange();
    });
  }
  @override
  void onTaskUpdate(TaskModel task) {
    if (!super.initialized) {
      init(() => onTaskUpdate(task));
    }
    super.repository.updateTask(task);
    sortTask(task);

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
    _uncategorizedTasks.remove(task);
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
      _listItems.add(filter.buildHeader());
      _listItems.addAll(filter.buildItems());
    }
  }

  void onChange() {
    rebuildFilters();
    notifyListeners();
  }
}
