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

  // main components of screen
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
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
                  icon: const Icon(Icons.more_vert),
                  tooltip: "Show menu",
                );
              },
              menuChildren: List<MenuItemButton>.generate(
                  1,
                  (index) => MenuItemButton(
                      onPressed: () {
                        _vm.deleteCompletedTasks();
                      },
                      child: const Text("Delete Completed Tasks"))))
        ]);
  }

  // build list of all tasks grouped and sorted by date.
  Widget buildList(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _vm.onRefresh,
        child: ChangeNotifierProvider(
            create: (_) => _vm,
            child: Consumer<TaskListVM>(
              builder: (context, tlvm, child) {
                return ListView(
                  children: [
                    buildOverdue(context),
                    buildToday(context),
                    buildUpcoming(context),
                  ],
                );
              },
            )));
  }

  // Build floating action button
  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: onAddTaskButton,
      child: const Icon(Icons.add),
    );
  }

  Widget buildOverdue(BuildContext context) {
    List<TaskModel> tasks = _vm.getOverdue();
    return ExpansionTile(
      title: Text(
        "Overdue",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      controlAffinity: ListTileControlAffinity.leading,
      initiallyExpanded: true,
      children: [...tasks.map((e) => TaskListItemWidget(e, _vm))],
    );
  }

  Widget buildToday(BuildContext context) {
    List<TaskModel> tasks = _vm.getTasksByDay(DateTimeConverter.today());
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        ListTile(
          title: Text(
            "Today",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          trailing: IconButton(
              onPressed: () => onAddTaskButton(day: DateTimeConverter.today()),
              icon: const Icon(Icons.add)),
        ),
        ...tasks.map((e) => TaskListItemWidget(e, _vm))
      ],
    );
  }

  Widget buildUpcoming(BuildContext context) {
    DateTime tod = DateTimeConverter.today();
    DateTime tom = DateTime(tod.year, tod.month, tod.day + 1);
    SplayTreeMap<DateTime, List<TaskModel>> tasks =
        _vm.getTasksGroupedByDate(start: tom);
    if(tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    return ExpansionTile(
        title: Text(
          "Upcoming",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        initiallyExpanded: false,
        children: [
          ...tasks.keys.map((e) {
            DateTime date = e;
            List<TaskModel> tasksByDate = tasks[e]!;
            String title;
            int dayComp = compareDates(date, DateTimeConverter.today());
            switch (dayComp) {
              case 0:
                title = "Today";
                break;
              case 1:
                title = "Tomorrow";
                break;
              default:
                title = "${formatDate(date)} ${getWeekday(date)}";
                break;
            }
            return Column(children: [
              ListTile(
                  title: Text(
                    "$title ${tasks[e]!.length}",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  trailing: IconButton(
                      onPressed: () => onAddTaskButton(day: date),
                      icon: const Icon(Icons.add))),
              ListView(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [...tasks[e]!.map((e) => TaskListItemWidget(e, _vm))],
              )
            ]);
          })
        ]);
  }

  void onAddTaskButton({DateTime? day}) {
    TaskModel task = TaskModel.createEmpty();
    if (day != null) {
      task.updateDeadline(day);
    }
    openEditTaskModal(task, _vm, context).then(
      (value) {
        value ?? _vm.addTask(value);
        _vm.render();
      },
    );
  }
}
