import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/editTask/EditTaskView.dart';
import 'package:todo_list/task/taskList/TaskList.dart';
import 'package:todo_list/task/taskList/TaskListVM.dart';
import 'package:todo_list/task/taskList/taskListItem/TaskListItem.dart';

class TaskListView extends State<TaskList> {
  late TaskListVM _vm;

  TaskListView();

  @override
  void initState() {
    super.initState();
    _vm = TaskListVM();
    _vm.getAllTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: buildList(context),
        floatingActionButton: buildFAB(context));
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
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
                  icon: const Icon(Icons.more_vert),
                  tooltip: "Show menu",
                );
              },
              menuChildren: List<MenuItemButton>.generate(
                  1,
                      (index) =>
                      MenuItemButton(
                          onPressed: () {
                            _vm.deleteCompletedTasks();
                          },
                          child: const Text("Delete Completed Tasks"))))
        ]);
  }

  Widget buildList(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _vm.onRefresh,
        child: ChangeNotifierProvider(
            create: (_) => _vm,
            child: Consumer<TaskListVM>(
              builder: (context, tlvm, child) {
                return ListView(
                  children: [
                    buildOverdueTasks(context),
                    buildToday(context),
                    buildTomorrow(context),
                    ...buildUpcoming(context),
                    buildCompleted(context)
                  ],
                );
              },
            )));
  }

  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(onPressed: () {
      openEditTaskModal(TaskModel.createEmpty(), _vm, context).then((value) {
        value ?? _vm.addTask(value);
        return value;
      });
    });
  }

  Widget buildHeader(String name, BuildContext context) {
    return Text(name);
  }

  Widget buildOverdueTasks(BuildContext context) {
    return ExpansionTile(
      title: buildHeader("Overdue", context),
      controlAffinity: ListTileControlAffinity.leading,
      children: [
        ..._vm.getOverdue().map((e) => TaskListItemWidget(e, _vm)).toList()
      ],
    );
  }

  List<Widget> buildUpcoming(BuildContext context) {
    List<Widget> upcoming = [];

    // constants
    final tod = DateTimeConverter.today();
    final start = DateTime(tod.year, tod.month, tod.day + 2); // start in 2 days
    SplayTreeMap<DateTime, Set<TaskModel>> tasks = _vm.getAfter(start);

    for (var key in tasks.keys) {
      String date = DateTimeConverter.formatDate(key);
      String day = getWeekday(key);
      upcoming.add(ExpansionTile(
        title: buildHeader("$day $date", context),
        children: [
          ...tasks[key]!.map(
                  (e) => TaskListItemWidget(e, _vm)),
        ],
        controlAffinity: ListTileControlAffinity.leading,),
      );
  }
    return upcoming;
  }

  Widget buildToday(BuildContext context) {
    return ExpansionTile(
      title: buildHeader("Today", context),
      children: [
        ..._vm
            .getByDay(DateTimeConverter.today())
            .map((e) => TaskListItemWidget(e, _vm))
            .toList()
      ],
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget buildTomorrow(BuildContext context) {
    final tod = DateTimeConverter.today();
    return ExpansionTile(title: buildHeader("Tomorrow", context),
      children: [
        ..._vm
            .getByDay(DateTime(tod.year, tod.month, tod.day + 1))
            .map((e) => TaskListItemWidget(e, _vm))
            .toList()
      ],
      controlAffinity: ListTileControlAffinity.leading,);
  }

  Widget buildCompleted(BuildContext context) {
    List<Widget> completed =
    _vm.getCompleted().map((e) => TaskListItemWidget(e, _vm)).toList();
    return ExpansionTile(
      title: buildHeader("Completed", context),
      controlAffinity: ListTileControlAffinity.leading,
      children: [...completed],
    );
  }
}
