import 'package:flutter/material.dart';
import 'package:todo_list/task/task_model.dart';
import 'package:todo_list/task/editTask/edit_task_view.dart';
import 'package:todo_list/task/taskList/task_list_vm.dart';

/// View model for a single task
class TaskListItemVM extends ChangeNotifier {
  final TaskModel _model;
  final TaskListVM _taskListVM;

  TaskListItemVM(this._model, this._taskListVM);

  get isComplete => _model.isComplete;

  get title => _model.title;

  get description => _model.description;

  get model => _model;

  get deadline => _model.deadline;

  // vm - view

  void onCheckToggle(bool? value) {
    _model.setComplete(value);
    _taskListVM.updateTask(_model);
    notifyListeners();
  }

  /// List item clicked. Open editing modal
  void onTap(BuildContext context) {
    openEditTaskModal(_model, _taskListVM, context).then(
      (value) => _taskListVM.onModalClose(),
    );
    notifyListeners();
  }
}
