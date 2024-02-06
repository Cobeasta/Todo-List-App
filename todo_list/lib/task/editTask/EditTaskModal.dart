
import 'package:flutter/material.dart';
import 'package:todo_list/task/taskList/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';

import 'EditTaskView.dart';

class EditTaskModal extends StatefulWidget {
  final TaskModel _task;
  final TaskListVMBase _taskListVM;
  TaskModel get task => _task;
  TaskListVMBase get taskListVM => _taskListVM;

  const EditTaskModal(this._task, this._taskListVM, {super.key});

  @override
  State<StatefulWidget> createState() {
    return EditTaskModalView();
  }
}




