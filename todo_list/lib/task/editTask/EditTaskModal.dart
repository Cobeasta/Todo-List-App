
import 'package:flutter/material.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/taskList/TaskListVM.dart';

import 'EditTaskView.dart';

class EditTaskModal extends StatefulWidget {
  final TaskModel _task;
  final TaskListVM _taskListVM;
  TaskModel get task => _task;
  TaskListVM get taskListVM => _taskListVM;

  const EditTaskModal(this._task, this._taskListVM, {super.key});

  @override
  State<StatefulWidget> createState() {
    return EditTaskModalView();
  }
}




