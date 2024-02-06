import 'package:flutter/material.dart';
import 'package:todo_list/task/taskList/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';

abstract class FilterItem {
  final UniqueKey _key;

  get key => _key;

  FilterItem() : _key = UniqueKey();

  Widget build(BuildContext context);
}

abstract class TaskListFilterBase {
  final TaskListVMBase _vm;

  get vm => _vm;
  final String _filterName;

  get filterName => _filterName;

  TaskListFilterBase(this._vm, this._filterName);


  List<Widget> listForGroupedItems();
  List<Widget> listForSortedItems();
  void clear();
  bool addTask(TaskModel model);

  void removeTask(TaskModel model);
}
