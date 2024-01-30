import 'package:flutter/material.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/task/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/TaskRepository.dart';

class TaskListVM extends TaskListVMBase {
  final List<TaskModel> _tasks = []; // model
  bool _loading = false;
  late TaskRepository _repository;
  bool _initialized = false;

  final bool _useScrollController = true;
  late final ScrollController _scrollController;

  TaskListVM() : super();

  get tasks => _tasks;

  @override
  void init(void Function() callback) async {
    _repository = await getIt.getAsync<TaskRepository>().then((repo) {
      if (!_initialized) {
        _repository = repo;
        _scrollController = ScrollController();
        if (_useScrollController) {
          _scrollController.addListener(handleScrollControllerUpdate);
        }
        _initialized = true; // Task repository is initialized
      }

      callback();

      return _repository;
    });
  }

  void handleScrollControllerUpdate() {}

  @override
  Future<void> onRefresh() async {
    if (!_initialized) {
      init(onRefresh);
      return;
    }
    update();
  }

  // interfacing with task repository
  @override
  void update() async {
    if (!_initialized) {
      init(update);
      return;
    }
    _loading = true;
    notifyListeners();
    List<TaskModel> tasks = await _repository.listTasks();

    _tasks.clear();
    _tasks.addAll(tasks);

    _loading = false;
    notifyListeners();
  }

  @override
  void addTask(TaskModel task) {
    if (!_initialized) {
      init(() => addTask(task));
      return;
    }
    _tasks.add(task);
    notifyListeners();
  }

  @override
  void removeTask(TaskModel task) {
    if (!_initialized) {
      init(() => removeTask(task));
      return;
    }
    _tasks.remove(task);
    notifyListeners();
  }
  @override
void onTaskUpdate(TaskModel task) {
    // nothing needs done for this list when a task is updated.
    return;
  }
}
