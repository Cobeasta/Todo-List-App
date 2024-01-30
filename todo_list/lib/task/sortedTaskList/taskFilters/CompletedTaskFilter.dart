import 'package:flutter/material.dart';
import 'package:todo_list/task/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/taskList/taskListItem/TaskListItemView.dart';

import 'TaskFilterBase.dart';

class HeaderTaskFilterItem extends FilterItem {
  String _title;

  HeaderTaskFilterItem(this._title);

  @override
  Widget build(BuildContext context) {
    return Text(_title);
  }
}

class TaskModelTaskFilterItem extends FilterItem {
  TaskModel _model;
  TaskListVMBase _vm;

  TaskModelTaskFilterItem(this._model, this._vm):super();

  @override
  Widget build(BuildContext context) {
    return TaskListItemWidget(_model, _vm, key: super.key);
  }
}

class CompletedTaskFilter extends TaskListFilterBase {
  final bool _reversed;
  final List<TaskModel> _filteredTasks = [];

  @override
  get itemCount => _filteredTasks.length;

  @override
  FilterItem buildHeader() {
    return HeaderTaskFilterItem(super.filterName);
  }
  @override
  List<FilterItem> buildItems() {
    List<FilterItem> items = [];
    for(var task in _filteredTasks) {
      items.add(TaskModelTaskFilterItem(task, super.vm ));
    }
    return items;
  }

  @override
  List<FilterItem> get items => [HeaderTaskFilterItem(super.filterName), ..._filteredTasks.map((e) => TaskModelTaskFilterItem(e, super.vm))];

  get filteredTasks => _filteredTasks;

  CompletedTaskFilter(this._reversed, vm)
      : super(vm, _reversed ? "Incomplete" : "Complete");

  @override
  bool match(TaskModel model) {
    return model.isComplete ^ _reversed;
  }


  @override
  void clear() {
    _filteredTasks.clear();
  }

  @override
  void removeTask(TaskModel model) {
    _filteredTasks.remove(model);
  }
  @override
  void addTask(TaskModel model) {
    if(match(model)) {
      _filteredTasks.add(model);
    }
  }
}
