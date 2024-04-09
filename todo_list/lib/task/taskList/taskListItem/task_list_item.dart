import 'package:flutter/material.dart';
import 'package:todo_list/task/taskList/task_list_vm.dart';
import 'package:todo_list/task/taskList/taskListItem/task_list_item_view.dart';
import 'package:todo_list/task/task_model.dart';

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