import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/task/TaskList/taskListItem/TaskListItemVM.dart';
import 'package:todo_list/task/TaskListBase.dart';
import 'package:todo_list/task/TaskModel.dart';

/// Entry state for task list item
class TaskListItemWidget extends StatefulWidget {
  final TaskModel _model;
  final TaskListVMBase _taskListVM;

  const TaskListItemWidget(this._model, this._taskListVM, {super.key});

  @override
  State<StatefulWidget> createState() => TaskItemView();
}

class TaskItemView extends State<TaskListItemWidget> {
  late TaskListItemVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = TaskListItemVM(widget._model, widget._taskListVM);
  }

  Widget buildCheckbox(BuildContext context) {
    return Checkbox(value: _vm.isComplete, onChanged: _vm.onCheckToggle);
  }

  Widget buildTitle(BuildContext context) {
    return Text(
      _vm.title,
    );
  }

  Widget buildSubtitle(BuildContext context) {
    return Text(_vm.description);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskListItemVM>(
      create: (context) => _vm,
      child: Consumer<TaskListItemVM>(
        builder: (context, tvm, child) {
          return Card(
            child: ListTile(
              leading: buildCheckbox(context),
              title: buildTitle(context),
              subtitle: buildSubtitle(context),
              onTap: () => tvm.onTap(context),
            ),
          );
        },
      ),
    );
  }
}
