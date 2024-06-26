import 'package:flutter/material.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/task/task_model.dart';
import 'package:todo_list/task/task_repository.dart';
import 'package:todo_list/task/taskList/task_list_vm.dart';

class EditTaskVM extends ChangeNotifier {
  late TaskRepository _repository;
  final TaskModel _taskModel;
  final TaskListVM _taskListVM;

  get task => _taskModel;

  EditTaskVM(this._taskListVM, this._taskModel);

  final TextEditingController _titleController = TextEditingController();

  TextEditingController get titleController => _titleController;
  final TextEditingController _descriptionController = TextEditingController();

  TextEditingController get descriptionController => _descriptionController;

  bool get isCompleted => _taskModel.isComplete;
  String get title => _taskModel.title;
  String get description => _taskModel.description;
  DateTime get deadline => _taskModel.deadline;

  void init() {
    _titleController.text = _taskModel.title;
    _descriptionController.text = _taskModel.description;

    getIt.getAsync<TaskRepository>().then((value) => start(value));
  }

  void start(TaskRepository repository) {
    _repository = repository;

    _titleController.addListener(() {
      _taskModel.updateTitle(_titleController.text);
    });
    _descriptionController.addListener(() {
      _taskModel.updateDescription(_descriptionController.text);
    });
  }

  void updateTitle() {
    _taskModel.updateTitle(_titleController.text);
    notifyListeners();
  }

  void updateDescription() {
    _taskModel.updateDescription(_descriptionController.text);
    notifyListeners();
  }

  void onCheckToggle(BuildContext context, bool? val) {
    _taskModel.setComplete(val);
    submit(context);
  }

  void updateDeadline(DateTime date) {
    _taskModel.updateDeadline(date);
    notifyListeners();
  }

  void delete(BuildContext context) {
    _taskListVM.removeTask(_taskModel);
    Navigator.pop(context);
  }

  void submit(BuildContext context) {
    if (_taskModel.id == null) {
      _repository.insertTask(_taskModel);
      _taskListVM.editTaskModalSubmit(_taskModel);
    } else {
      _repository.updateTask(_taskModel);
    }
    notifyListeners();
    Navigator.pop(context, _taskModel);
  }
}
