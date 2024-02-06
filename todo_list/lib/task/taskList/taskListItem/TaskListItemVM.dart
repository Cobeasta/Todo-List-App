import 'package:flutter/material.dart';
import 'package:todo_list/task/taskList/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/editTask/EditTaskView.dart';

/// View model for a single task
class TaskListItemVM extends ChangeNotifier {
  final TaskModel _model;
  final TaskListVMBase _taskListVM;

  TaskListItemVM(this._model, this._taskListVM);

  get isComplete => _model.isComplete;

  get title => _model.title;

  get description => _model.description;

  get model => _model;

  get deadline => _model.deadline;

  // vm - view

  void onCheckToggle(bool? value) {
    _model.setComplete(value);
    _taskListVM.onTaskUpdate(_model);
    notifyListeners();
  }

  /// List item clicked. Open editing modal
  void onTap(BuildContext context) {
    openEditTaskModal(_model, _taskListVM, context);
    notifyListeners();
  }
}