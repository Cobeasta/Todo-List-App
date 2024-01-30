import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/task/EditTaskModal.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/taskList/TaskListVM.dart';
import 'package:todo_list/task/taskList/taskListItem/TaskListItemView.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key, required this.title});

  final String title;

  @override
  State<TaskList> createState() => TaskListView();
}

class TaskListView extends State<TaskList> {
  late TaskListVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = TaskListVM();
    _vm.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: ChangeNotifierProvider(
            create: (_) => _vm,
            child: Consumer<TaskListVM>(
              builder: (context, tasklistvm, child) {
                return RefreshIndicator(
                  onRefresh: _vm.onRefresh,
                  child: ListView.builder(
                    itemCount: tasklistvm.tasks.length,
                    itemBuilder: (context, index) {
                      return TaskListItemWidget(tasklistvm.tasks[index], _vm);
                    },
                  ),
                );
              },
            )),
        floatingActionButton: FloatingActionButton(onPressed: () {
          openEditTaskModal(TaskModel.createEmpty(), _vm, context).then((val) {
            _vm.addTask(val);
            return val;
          });
        }));
  }
}
