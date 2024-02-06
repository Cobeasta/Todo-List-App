import 'package:flutter/material.dart';
import 'package:todo_list/task/taskList/taskListItem/TaskListItemView.dart';
import 'package:todo_list/task/taskList/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';

/// Entry state for task list item
class TaskListItemWidget extends StatefulWidget {
  final TaskModel _model;
  final TaskListVMBase _taskListVM;
  final UniqueKey _key = UniqueKey();



  TaskListItemWidget(this._model, this._taskListVM, {super.key} );

  @override
  State<StatefulWidget> createState() => TaskItemView();

  TaskModel get model => _model;
  TaskListVMBase get taskListVM => _taskListVM;

  @override
  UniqueKey get key => _key;
}