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

  bool get showCompleted => _vm.showCompleted;

  TaskListView();

  @override
  void initState() {
    super.initState();
    _vm = TaskListVM();
    _vm.getAllTasks();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => _vm,
        child: Consumer<TaskListVM>(
          builder: (context, value, child) {
            return Scaffold(
                appBar: buildAppBar(context),
                body: buildList(context),
                floatingActionButton: buildFAB(context));
          },
        ));
  }

  // main components of screen
  final MenuController _overflowController = MenuController();

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_vm.mode.name),
        actions: [
          MenuAnchor(
              controller: _overflowController,
              menuChildren: [
                SubmenuButton(
                  menuChildren: [
                    RadioMenuButton(
                        value: TaskListModes.today,
                        groupValue: _vm.mode,
                        onChanged: (value) => _vm.configure(mode: value),
                        child: const Text("Today")),
                    RadioMenuButton(
                        value: TaskListModes.week,
                        groupValue: _vm.mode,
                        onChanged: (value) => _vm.configure(mode: value),
                        child: const Text("Next 7 Days")),
                    RadioMenuButton(
                        value: TaskListModes.upcoming,
                        groupValue: _vm.mode,
                        onChanged: (value) => _vm.configure(mode: value),
                        child: const Text("Today")),
                  ],
                  child: Text(
                    "Mode",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                MenuItemButton(
                  onPressed: () => _vm.configure(showOverdue: !_vm.showOverdue),
                  leadingIcon: Icon(_vm.showOverdue
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded),
                  child: const Text("Show Overdue"),
                ),
                MenuItemButton(
                  onPressed: () =>
                      _vm.configure(showCompleted: !_vm.showCompleted),
                  leadingIcon: Icon(_vm.showCompleted
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded),
                  child: const Text("Show Completed"),
                ),
                MenuItemButton(
                  child: const Text("Delete Completed"),
                  onPressed: () {
                    _vm.deleteCompletedTasks();
                  },
                ),
              ],
              onOpen: () {},
              onClose: () {},
              child: IconButton(
                onPressed: () {
                  if (_overflowController.isOpen) {
                    _overflowController.close();
                  } else {
                    _overflowController.open();
                  }
                },
                icon: const Icon(Icons.more_vert),
                tooltip: "Show menu",
              ))
        ]);
  }

// build list of all tasks grouped and sorted by date.
  Widget buildList(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _vm.onRefresh,
        child: ListView(shrinkWrap: true, physics: const ClampingScrollPhysics(), children: [
          buildOverdue(context),
          buildTasks(context),
          buildCompleted(context)
        ]));
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
    if (!_vm.showOverdue || tasks.isEmpty) {
      return const SizedBox.shrink();
    }
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

  Widget buildTasks(BuildContext context) {
    DateTime tod = DateTimeConverter.today();
    SplayTreeMap<DateTime, List<TaskModel>> tasks = _vm.getTasksMain();

    if (_vm.mode == TaskListModes.today &&
        tasks[tod] == null &&
        _vm.getOverdue().isEmpty) {
      return Column(
        children: [
          Text(
              "${formatDate(DateTimeConverter.today())} ${getWeekday(DateTimeConverter.today())}"),
          Text(
            "Nothing left to do today",
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
      );
    }
    List<DateTime> days = tasks.keys.toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: days.length,
      itemBuilder: (context, index) {
        DateTime date = days[index];
        if (tasks[date] == null) return const SizedBox.shrink();
        List<TaskModel> daysTasks = tasks[date]!;

        int dayComp = compareDates(date, tod);
        String dateStr = formatDate(date);
        String weekday = getWeekday(date);
        String titleStr;
        if (_vm.mode == TaskListModes.today) {
          titleStr = "$dateStr $weekday";
        } else if (dayComp == 0) {
          titleStr = "$dateStr Today $weekday";
        } else if (dayComp == 1) {
          titleStr = "$dateStr Tomorrow $weekday";
        } else {
          titleStr = "$dateStr $weekday";
        }
        Text title = Text(
          titleStr,
          style: Theme.of(context).textTheme.headlineSmall,
        );
        Text subtitle;

        if (tasks[date]!.isEmpty) {
          subtitle = Text(
            "Notasks due",
            style: Theme.of(context).textTheme.bodyLarge,
          );
        } else if (tasks[date]!.length > 1) {
          subtitle = Text(
            "${tasks[date]!.length} tasks due",
            style: Theme.of(context).textTheme.bodyLarge,
          );
        } else {
          subtitle = Text(
            "${tasks[date]!.length} task due",
            style: Theme.of(context).textTheme.bodyLarge,
          );
        }
        return Column(children: [
          ListTile(
              title: title,
              subtitle: subtitle,
              trailing: IconButton(
                  onPressed: () => onAddTaskButton(day: date),
                  icon: const Icon(Icons.add))),
          ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: [...daysTasks.map((e) => TaskListItemWidget(e, _vm))],
          )
        ]);
      },
    );
  }

  Widget buildCompleted(BuildContext context) {
    if (!_vm.showCompleted) {
      return const SizedBox.shrink();
    }
    List<Widget> tasks =
        _vm.getCompleted().map((e) => TaskListItemWidget(e, _vm)).toList();
    return ExpansionTile(
      title: Text(
        "Completed",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      controlAffinity: ListTileControlAffinity.leading,
      initiallyExpanded: false,
      children: [...tasks],
    );
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
