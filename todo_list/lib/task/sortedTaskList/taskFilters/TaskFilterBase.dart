import 'package:flutter/material.dart';
import 'package:todo_list/task/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';

abstract class FilterItem {
  final UniqueKey _key;
  get key => _key;
  FilterItem(): _key = UniqueKey();
  Widget build(BuildContext context);
}

abstract class TaskListFilterBase {
  final TaskListVMBase _vm;

  get vm => _vm;
  final String _filterName;

  get filterName => _filterName;

  int get itemCount;

  TaskListFilterBase(this._vm, this._filterName);

  List<FilterItem> get items;

  bool match(TaskModel model);

  void clear();

  void addTask(TaskModel model);
  void removeTask(TaskModel model);

  FilterItem buildHeader();

  List<FilterItem> buildItems();

  }
