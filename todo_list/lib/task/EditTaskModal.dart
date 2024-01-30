import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo_list/task/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/TaskRepository.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/data/TaskData.dart';

class EditTaskModal extends StatefulWidget {
  final TaskModel _task;
  final TaskListVMBase _taskListVM;

  get task => _task;

  const EditTaskModal(this._task, this._taskListVM, {super.key});

  @override
  State<StatefulWidget> createState() {
    return EditTaskModalView();
  }
}

class NewTaskVM extends ChangeNotifier {
  late TaskRepository _repository;
  final TaskModel _taskModel;
  final TaskListVMBase _taskListVM;

  get task => _taskModel;

  NewTaskVM(this._taskListVM, this._taskModel);

  bool _initialized = false;

  final TextEditingController _titleController = TextEditingController();

  TextEditingController get titleController => _titleController;
  final TextEditingController _descriptionController = TextEditingController();

  TextEditingController get descriptionController => _descriptionController;

  void init() {
    _initialized = false;
    _titleController.text = _taskModel.title == null ? "" : _taskModel.title!;
    _descriptionController.text =
        _taskModel.description == null ? "" : _taskModel.description!;

    getIt.getAsync<TaskRepository>().then(start);
  }

  void start(TaskRepository repository) {
    _repository = repository;

    _titleController.addListener(() {
      _taskModel.updateTitle(_titleController.text);
    });
    _descriptionController.addListener(() {
      _taskModel.updateDescription(_descriptionController.text);
    });
    _initialized = true;
  }

  void updateTitle() {
    _taskModel.updateTitle(_titleController.text);
  }

  void updateDescription() {
    _taskModel.updateDescription(_descriptionController.text);
  }

  void delete(BuildContext context) {
    Task toDelete = _taskModel.getData();
    _repository.deleteTask(toDelete.id!);
    _taskListVM.removeTask(_taskModel);
    Navigator.pop(context);
  }

  void submit(BuildContext context) {
    if (_taskModel.id == null) {
      _repository
          .insertTask(_taskModel)
          .then((value) => print("Inserted task"));
    } else {
      _repository.updateTask(_taskModel);
    }

    Navigator.pop(context, _taskModel);
  }
}

class EditTaskModalView extends State<EditTaskModal> {
  late NewTaskVM _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = NewTaskVM(widget._taskListVM, widget._task);
    _viewmodel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(hintText: "Item name"),
                controller: _viewmodel.titleController,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "Description"),
                controller: _viewmodel.descriptionController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        _viewmodel.delete(context);
                      },
                      icon: const Icon(Icons.delete)),
                  IconButton(
                      onPressed: () {
                        _viewmodel.submit(context);
                      },
                      icon: const Icon(Icons.send)),
                ],
              ),
            ]));
  }
}

Future<dynamic> openEditTaskModal(
    TaskModel task, TaskListVMBase taskListVM, BuildContext context) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return EditTaskModal(task, taskListVM);
      });
}
