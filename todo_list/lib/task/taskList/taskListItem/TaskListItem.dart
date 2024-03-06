import 'package:flutter/material.dart';
import 'package:todo_list/task/taskList/TaskListVM.dart';
import 'package:todo_list/task/taskList/taskListItem/TaskListItemView.dart';
import 'package:todo_list/task/TaskModel.dart';

/// Entry state for task list item
class TaskListItemWidget extends StatefulWidget {
  final TaskModel _model;
  final TaskListVM _taskListVM;
  final UniqueKey _key = UniqueKey();
  final bool showCheckbox;



  TaskListItemWidget(this._model, this._taskListVM, {super.key, this.showCheckbox = true} );

  @override
  State<StatefulWidget> createState() => TaskItemView();

  TaskModel get model => _model;
  TaskListVM get taskListVM => _taskListVM;

  @override
  UniqueKey get key => _key;
}