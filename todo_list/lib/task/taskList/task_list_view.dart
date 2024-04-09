import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/editTask/EditTaskView.dart';
import 'package:todo_list/task/taskList/TaskList.dart';
import 'package:todo_list/task/taskList/TaskListVM.dart';
import 'package:todo_list/task/taskList/taskListItem/TaskListItem.dart';

class TaskListView extends State<TaskList> {
  late TaskListVM _vm;

  String get screenName => widget.screenName;

  // main components of screen
  final MenuController _overflowController = MenuController();
  static const div = Divider(
    height: 5,
    thickness: 5,
    indent: 0,
    endIndent: 0,
  );

  TaskListView();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("TaskListView initState");
    }

    _vm = TaskListVM();
    _vm.init();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("TaskListView build");
    }



    return ChangeNotifierProvider<TaskListVM>.value(
        value: _vm,
        child: Consumer<TaskListVM>(
          builder: (context, vm, child) {
            if (!vm.settingsInitialized) {
              if (kDebugMode) {
                print("TaskListView VM settings not initialized");
              }
              return const SizedBox.shrink();
            }

            return Scaffold(
              appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: Text(vm.mode.name),
                  actions: [buildOverflow(context, vm)]),
              body: buildBody(context, vm),
              floatingActionButton: buildFAB(context, vm),
            );
          },
        ));
  }

  //  Main list
  Widget buildBody(BuildContext context, TaskListVM vm) {

    if (!vm.repositoryInitialized || vm.loading) {
      return Stack(alignment: Alignment.topCenter, children: [
        Positioned(
            top: 70,
            child:
            LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 50)),
      ]);
    }
    return RefreshIndicator(
        onRefresh: vm.onRefresh,
        child: ListView(
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              buildOverdue(context, vm),
              buildToday(context, vm),
              buildUpcoming(context, vm),
              buildCompleted(context, vm),
            ]));
  }

  /**
   * Build overflow menu for appbar. Includes configurations for list view.
   */
  Widget buildOverflow(BuildContext context, TaskListVM vm) {
    return MenuAnchor(
        controller: _overflowController,
        menuChildren: [
          SubmenuButton(
            menuChildren: [
              RadioMenuButton(
                  value: TaskListModes.today,
                  groupValue: vm.mode,
                  onChanged: (value) => vm.configure(mode: value),
                  child: const Text("Today")),
              RadioMenuButton(
                  value: TaskListModes.week,
                  groupValue: vm.mode,
                  onChanged: (value) => vm.configure(mode: value),
                  child: const Text("Next 7 Days")),
              RadioMenuButton(
                  value: TaskListModes.upcoming,
                  groupValue: vm.mode,
                  onChanged: (value) => vm.configure(mode: value),
                  child: const Text("Upcoming")),
            ],
            child: Text(
              "Mode",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          MenuItemButton(
            onPressed: () => vm.configure(showOverdue: !vm.showOverdue),
            leadingIcon: Icon(vm.showOverdue
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded),
            child: const Text("Show Overdue"),
          ),
          MenuItemButton(
            onPressed: () => vm.configure(showCompleted: !vm.showCompleted),
            leadingIcon: Icon(vm.showCompleted
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded),
            child: const Text("Show Completed"),
          ),
          MenuItemButton(
            child: const Text("Delete Completed"),
            onPressed: () {
              vm.deleteCompletedTasks();
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
        ));
  }

  /**
   * Build widget for all overdue tasks. If set to hide overdue tasks,
   * sizedbox.shrink is used.
   */
  Widget buildOverdue(BuildContext context, TaskListVM vm) {
    List<TaskModel> overdue = [];

    if (vm.showOverdue) {
      return const SizedBox.shrink();
    }
    overdue = vm.getOverdue();

    return overdue.isNotEmpty
        ? ExpansionTile(
            title: Text(
              "Overdue",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            controlAffinity: ListTileControlAffinity.leading,
            initiallyExpanded: true,
            children: [
                ...overdue.map((e) => TaskListItemWidget(e, vm))
              ]) //overdue expansion tile
        : const SizedBox.shrink();
  }

  /**
   * Build today's tasks as a listview.
   */
  Widget buildToday(BuildContext context, TaskListVM vm) {
    List<TaskModel> today = vm.getToday();
    DateTime tod = DateTimeConverter.today();

    return today.isNotEmpty
        ? ListView(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  "${formatDate(tod)} \u2022 ${vm.mode == TaskListModes.today ? getWeekday(tod) : "Today \u2022 ${getWeekday(tod)}"}",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ...today.map((e) => TaskListItemWidget(e, vm)),
            ],
          )
        : vm.mode == TaskListModes.today
            ? ListTile(
                title: Text("Nothing due today",
                    style: Theme.of(context).textTheme.headlineSmall),
              )
            : const SizedBox.shrink();
  }

  /**
   * Build upcoming tasks widgets as a listview.
   */
  Widget buildUpcoming(BuildContext context, TaskListVM vm) {
    Map<DateTime, List<TaskModel>> upcoming = {};
    List<DateTime> taskDays = [];

    DateTime tod = DateTimeConverter.today();

    if (vm.mode == TaskListModes.today) {
      return const SizedBox.shrink();
    }

    upcoming = vm.getUpcoming();
    taskDays = upcoming.keys.toList();

    return upcoming.isNotEmpty
        ? ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: taskDays.length,
            itemBuilder: (context, index) {
              DateTime date = taskDays[index];
              List<TaskModel> dayTasks = upcoming[date]!;

              String dateStr = formatDate(date);
              String weekday = getWeekday(date);
              int relativeDay = daysUntil(date);

              String titleStr;
              if (relativeDay == 1) {
                titleStr = "$dateStr \u2022 Tomorrow \u2022 $weekday";
              } else {
                titleStr = "$dateStr \u2022  $weekday";
              }

              String subtitle = "${upcoming.length} tasks due";

              if (upcoming.isEmpty) {
                subtitle = "No tasks due";
              } else if (upcoming.length == 1) {
                subtitle = "${upcoming.length} task due";
              }
              return ListView(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text(
                      titleStr,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          TaskModel model = TaskModel.createEmpty();
                          model.updateDeadline(date);
                          openEditTaskModal(model, vm, context).then(
                            (value) {
                              if (value != null) {
                                vm.addTask(value);
                              }
                              vm.onModalClose();
                            },
                          );
                        },
                        icon: const Icon(Icons.add)),
                  ),
                  ...dayTasks.map((e) => TaskListItemWidget(e, vm)),
                  div,
                ],
              );
            },
          )
        : const SizedBox.shrink();
  }

  Widget buildCompleted(BuildContext context, TaskListVM vm) {
    List<TaskModel> completed = [];

    if (!vm.showCompleted) {
      return const SizedBox.shrink();
    }
    completed = vm.getComplete();
    completed.sort(
      (a, b) => compareDates(a.deadline, b.deadline),
    );

    return vm.showCompleted && completed.isNotEmpty
        ? ExpansionTile(
            title: Text(
              "Completed",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            controlAffinity: ListTileControlAffinity.leading,
            initiallyExpanded: false,
            children: [
              ...completed.map((e) => TaskListItemWidget(
                    e,
                    vm,
                    showCheckbox: false,
                  ))
            ],
          )
        : const SizedBox.shrink();
  }

  Widget buildFAB(BuildContext context, TaskListVM vm) {
    return FloatingActionButton(
      onPressed: () {
        TaskModel task = TaskModel.createEmpty();
        openEditTaskModal(task, vm, context).then(
          (value) {
            if (value != null) {
              vm.addTask(value);
            }
            vm.onModalClose();
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
