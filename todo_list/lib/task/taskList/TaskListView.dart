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
  // Build floating action button
  Widget buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        openEditTaskModal(TaskModel.createEmpty(), _vm, context).then(
          (value) {
            value ?? _vm.addTask(value);
            _vm.render();
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }

  // building sub-lists
  Widget buildOverdueTasks(BuildContext context) {
    // get overdue tasks
    List<TaskModel> tasks = _vm.getOverdue();
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    return buildExpansionTile(context, "Overdue", tasks,
        initiallyExpanded: true);
  }
  Widget buildToday(BuildContext context) {
    // get tasks due today,then build a widget for the expandable list
    List<TaskModel> tasks = _vm.getByDay(DateTimeConverter.today());
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    return buildExpansionTile(context, "Today", tasks, initiallyExpanded: true);
  }
  Widget buildTomorrow(BuildContext context) {
    final tod = DateTimeConverter.today();
    List<TaskModel> tasks =
        _vm.getByDay(DateTime(tod.year, tod.month, tod.day + 1));
    return buildExpansionTile(context, "Tomorrow", tasks);
  }
  List<Widget> buildUpcoming(BuildContext context) {
    List<Widget> upcoming = [];
    // constants
    final tod = DateTimeConverter.today();
    final start = DateTime(tod.year, tod.month, tod.day + 2); // start in 2 days
    SplayTreeMap<DateTime, Set<TaskModel>> tasks = _vm.getAfter(start);

    for (var key in tasks.keys) {
      if(tasks[key] != null && tasks[key]!.isEmpty) {
        continue;
      }
      String date = DateTimeConverter.formatDate(key);
      String day = getWeekday(key);
      upcoming.add(buildExpansionTile(context, "$day $date", tasks[key]!));
      if (upcoming.isEmpty) {
        if (tasks.isEmpty) {
          return [const SizedBox.shrink()];
        }
      }
    }
    return upcoming;
  }
  Widget buildCompleted(BuildContext context) {
    List<TaskModel> completed = _vm.getCompleted().toList();
    if (completed.isEmpty) {
      return const SizedBox.shrink();
    }
    return buildExpansionTile(context, "Completed", [...completed]);
  }


// reused widget building patterns
  Widget buildHeader(String name, BuildContext context) {
    return Text(
      name,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
  Widget buildExpansionTile(
      BuildContext context, String title, Iterable<TaskModel> tasks,
      {initiallyExpanded = false}) {
    return ExpansionTile(
      title: buildHeader(title, context),
      controlAffinity: ListTileControlAffinity.leading,
      initiallyExpanded: initiallyExpanded,
      trailing: Text(
        "${tasks.length}",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      children: [
        ...tasks.map(
          (e) => TaskListItemWidget(e, _vm),
        )
      ],
    );
  }
}
