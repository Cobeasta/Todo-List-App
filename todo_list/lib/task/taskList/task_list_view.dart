import 'dart:collection';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/date_utils.dart';
import 'package:todo_list/task/task_model.dart';
import 'package:todo_list/task/editTask/edit_task_view.dart';
import 'package:todo_list/task/taskList/task_list.dart';
import 'package:todo_list/task/taskList/task_list_vm.dart';
import 'package:todo_list/task/taskList/taskListItem/task_list_item.dart';

class TaskListView extends State<TaskList> {
  late TaskListVM _vm;

  String get screenName => widget.screenName;

  // main components of screen
  final MenuController _overflowController = MenuController();

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

  /// Build overflow menu for appbar. Includes configurations for list view.
  Widget buildOverflow(BuildContext context, TaskListVM vm) {
    return MenuAnchor(
        controller: _overflowController,
        menuChildren: [
          SubmenuButton(
            // submenu for task list view mode
            menuChildren: [
              RadioMenuButton(
                  value: TaskListModes.today,
                  groupValue: vm.mode,
                  onChanged: (value) => vm.selectViewMode(TaskListModes.today),
                  child: const Text("Today")),
              RadioMenuButton(
                  value: TaskListModes.week,
                  groupValue: vm.mode,
                  onChanged: (value) => vm.selectViewMode(TaskListModes.week),
                  child: const Text("Next 7 Days")),
              RadioMenuButton(
                  value: TaskListModes.upcoming,
                  groupValue: vm.mode,
                  onChanged: (value) =>
                      vm.selectViewMode(TaskListModes.upcoming),
                  child: const Text("Upcoming")),
            ],
            child: Text(
              "Mode",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ), // TaskList mode select
          MenuItemButton(
            onPressed: () => vm.toggleShowOverdue(!vm.showOverdue),
            leadingIcon: Icon(vm.showOverdue
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded),
            child: const Text("Show Overdue"),
          ), // Toggle showing overdue tasks
          MenuItemButton(
            onPressed: () => vm.toggleShowCompleted(!vm.showCompleted),
            leadingIcon: Icon(vm.showCompleted
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded),
            child: const Text("Show Completed"),
          ), // toggle showing completed tasks
          MenuItemButton(
            child: const Text("Delete Completed"),
            onPressed: () {
              vm.removeAllCompleted();
            },
          ), // Action delete all completed tasks
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

  /// Build main body. Top level activities like refreshing, loading,
  /// and building the whole list
  Widget buildBody(BuildContext context, TaskListVM vm) {
    if (!vm.repositoryInitialized || vm.loading) {
      return Stack(alignment: Alignment.topCenter, children: [
        Positioned(
            top: 70,
            child:
                LoadingAnimationWidget.waveDots(color: Colors.white, size: 50)),
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

  /// Build widget for all overdue tasks. If set to hide overdue tasks,
  /// sized box.shrink is used.
  Widget buildOverdue(BuildContext context, TaskListVM vm) {
    Set<TaskModel> overdue = SplayTreeSet<TaskModel>();

    if (vm.showOverdue) {
      return const SizedBox.shrink();
    }
    overdue = vm.tasksOverdue;

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

  /// Build today's tasks as a listview.
  Widget buildToday(BuildContext context, TaskListVM vm) {
    Set<TaskModel> tasks = vm.tasksDueToday;
    DateTime tod = TaskListDateUtils.today();

    return tasks.isNotEmpty
        ? ListView(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  "${TaskListDateUtils.formatDate(tod)} \u2022 ${vm.mode == TaskListModes.today ? TaskListDateUtils.getWeekday(tod) : "Today \u2022 ${TaskListDateUtils.getWeekday(tod)}"}",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              ...tasks.map((e) => TaskListItemWidget(e, vm)),
            ],
          )
        : vm.mode == TaskListModes.today
            ? ListTile(
                title: Text("Nothing due today",
                    style: Theme.of(context).textTheme.headlineSmall),
              )
            : const SizedBox.shrink();
  }

  /// Build upcoming tasks widgets as a listview.
  Widget buildUpcoming(BuildContext context, TaskListVM vm) {
    Map<DateTime, List<TaskModel>> upcoming = {};
    List<DateTime> taskDays = [];

    if (vm.mode == TaskListModes.today) {
      return const SizedBox.shrink();
    }

    upcoming = vm.tasksUpcoming;
    taskDays = upcoming.keys.toList();

    return upcoming.isNotEmpty
        ? ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: taskDays.length,
            itemBuilder: (context, index) {
              // build sublist  for each day

              DateTime date = taskDays[index]; // date for sublist
              List<TaskModel> dayTasks = upcoming[date]!; // daily tasks

              //  Building header
              String dateStr = TaskListDateUtils.formatDate(date);
              String weekday = TaskListDateUtils.getWeekday(date);
              int relativeDay = TaskListDateUtils.daysUntil(date);

              String title = (relativeDay == 1)
                  ? "$dateStr \u2022 Tom \u2022 $weekday"
                  : "$dateStr \u2022  $weekday";

              Text? subtitle;
              if (dayTasks.isNotEmpty) {
                Text subtitle =Text( dayTasks.length == 1
                    ? "1 task due"
                    : "${dayTasks.length} tasks due",
                style: Theme.of(context).textTheme.bodyMedium,);
              }

              Header header = Header(
                title: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subTitle: subtitle ?? const SizedBox.shrink()
              );

              return ListView(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  header,
                  ...dayTasks.map((e) => TaskListItemWidget(e, vm)),
                ],
              );
            },
          )
        : const SizedBox.shrink();
  }

  Widget buildCompleted(BuildContext context, TaskListVM vm) {
    Set<TaskModel> completed = <TaskModel>{};

    if (!vm.showCompleted) {
      return const SizedBox.shrink();
    }
    completed = vm.tasksCompleted;

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
              vm.editTaskModalSubmit(value);
            }
            vm.onModalClose();
          },
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

// Custom list tile definition
class Header extends StatelessWidget {
  final Widget? leading; // Optional leading widget
  final Text? title; // Required title text
  final Widget? subTitle; // Optional subtitle text
  final Function? onTap; // Optional tap event handler
  final Function? onLongPress; // Optional long press event handler
  final Function? onDoubleTap; // Optional double tap event handler
  final Widget? trailing; // Optional trailing widget
  final Color? tileColor; // Optional tile background color

  // Constructor for the custom list tile
  const Header({
    super.key,
    this.leading,
    this.title,
    this.subTitle,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.trailing,
    this.tileColor, // Make height required for clarity
  });


  @override
  Widget build(BuildContext context) {
    return Material(
      // Material design container for the list tile
      color: tileColor, // Set background color if provided
      elevation: 2.0,
      child: InkWell(
        // Tappable area with event handlers
        onTap: () => onTap, // Tap event handler
        onDoubleTap: () => onDoubleTap, // Double tap event handler
        onLongPress: () => onLongPress, // Long press event handler
        child: Wrap(
            // Constrain the size of the list tile
            children: [
              Column(children: [
                div,
                Row(
                  // Row layout for list item content
                  children: [
                    Padding(
                      // Padding for the leading widget
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: leading, // Display leading widget
                    ),
                    Expanded(
                      // Expanded section for title and subtitle
                      child: Column(
                        // Column layout for title and subtitle
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Align text left
                        children: [
                          title ?? const SizedBox(),
                          // Spacing between title and subtitle
                          subTitle ?? const SizedBox(),
                          // Display subtitle or empty space
                        ],
                      ),
                    ),
                    Padding(
                      // Padding for the trailing widget
                      padding: const EdgeInsets.all(12.0),
                      child: trailing, // Display trailing widget
                    )
                  ],
                ),
                div
              ])
            ]),
      ),
    );
  }
}

const div = Divider(
  height: 1,
  thickness: 1,
  indent: 0,
  endIndent: 0,
);
