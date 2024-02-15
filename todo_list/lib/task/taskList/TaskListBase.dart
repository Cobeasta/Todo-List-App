import 'package:flutter/material.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/TaskRepository.dart';

abstract class TaskListVMBase extends ChangeNotifier {
  late TaskRepository _repository;
  TaskRepository get  repository => _repository;
  bool _initialized = false;
  get initialized => _initialized;

  void init(void Function() callback) async {
    _repository = await getIt.getAsync<TaskRepository>().then((repo) {
      if (!_initialized) {
        _repository = repo;

        _initialized = true; // Task repository is initialized
      }
      callback();
      return _repository;
    });
  }

  void addTask(TaskModel model);

  void removeTask(TaskModel model);

  Future<void> onRefresh();

  void updateTask(TaskModel model) async {
    await _repository.updateTask(model);
    notifyListeners();
  }

}