import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/task/EditTaskModal.dart';
import 'package:todo_list/task/TaskList/taskListItem/TaskListItemView.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/sortedTaskList/FilteredTaskList.dart';
import 'package:todo_list/task/sortedTaskList/FilteredTaskListVM.dart';

class FilteredTaskListView extends State<FilteredTaskList> {
  late FilteredTaskListVM _vm;

  FilteredTaskListView();

  @override
  void initState() {
    super.initState();
    _vm = FilteredTaskListVM();
    _vm.update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            actions: [
              MenuAnchor(
                builder: (context, controller, child) {
                  return IconButton(
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: Icon(Icons.more_vert),
                    tooltip: "Show menu",
                  );
                },
                menuChildren: List<MenuItemButton>.generate(
                     1,
                        (index) => MenuItemButton(
                          onPressed: () {
                            _vm.deleteCompletedTasks();
                          },
                            child: Text("Delete Completed Tasks")))
              )
            ]),
        body: RefreshIndicator(
            onRefresh: _vm.onRefresh,
            child: ChangeNotifierProvider(
                create: (_) => _vm,
                child: Consumer<FilteredTaskListVM>(
                  builder: (context, tlvm, child) {
                    return ListView.builder(
                      itemCount: tlvm.listItems.length,
                      itemBuilder: (context, index) {
                        return tlvm.listItems[index].build(context);
                      },
                    );
                  },
                ))),
        floatingActionButton: FloatingActionButton(onPressed: () {
          openEditTaskModal(TaskModel.createEmpty(), _vm, context)
              .then((value) {
            _vm.addTask(value);
            return value;
          });
        }));
  }

  Widget buildHeader(String name, BuildContext context) {
    return Text(name);
  }

  List<Widget> buildTasks(List<TaskModel> tasks, BuildContext context) {
    List<Widget> taskWidgets = [];
    for (var task in tasks) {
      Widget taskWidget = TaskListItemWidget(task, _vm);
      taskWidgets.add(taskWidget);
    }
    return taskWidgets;
  }
}
