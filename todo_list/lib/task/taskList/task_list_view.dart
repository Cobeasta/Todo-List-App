import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/di.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/task/editTask/EditTaskView.dart';
import 'package:todo_list/task/taskList/TaskList.dart';
import 'package:todo_list/task/taskList/TaskListVM.dart';
import 'package:todo_list/task/taskList/taskListItem/TaskListItem.dart';
import 'package:injectable/injectable.dart';

class TaskListView extends State<TaskList> {
  late TaskListVM _vm;
  bool _initialized = false;

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
    getIt.getAsync<TaskListVM>().then((value) {
      _vm = value;
      _vm.getAllTasks();
      _initialized = true;
    });

  }

  @override
  Widget build(BuildContext context) {
    if(!_initialized) {
      return const SizedBox.shrink();
    }
    DateTime tod = DateTimeConverter.today();
    return ChangeNotifierProvider(
        create: (_) => _vm,
        child: Consumer<TaskListVM>(
          builder: (context, vm, child) {
            List<TaskModel> overdue = [];
            List<TaskModel> today = [];
            List<TaskModel> completed = [];
            List<DateTime> taskDays = [];
            Map<DateTime, List<TaskModel>> upcoming = {};
            if (vm.showOverdue) {
              overdue = vm.getOverdue();
            }
            if (vm.showCompleted) {
              completed = vm.getComplete();
              completed.sort(
                (a, b) => compareDates(a.deadline, b.deadline),
              );
            }
            today = vm.getToday();
            if (vm.mode != TaskListModes.today) {
              upcoming = vm.getUpcoming();
              taskDays = upcoming.keys.toList();
            }
            return Scaffold(
                appBar: AppBar(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    title: Text(vm.mode.name),
                    actions: [
                      MenuAnchor(
                          controller: _overflowController,
                          menuChildren: [
                            SubmenuButton(
                              menuChildren: [
                                RadioMenuButton(
                                    value: TaskListModes.today,
                                    groupValue: vm.mode,
                                    onChanged: (value) =>
                                        vm.configure(mode: value),
                                    child: const Text("Today")),
                                RadioMenuButton(
                                    value: TaskListModes.week,
                                    groupValue: vm.mode,
                                    onChanged: (value) =>
                                        vm.configure(mode: value),
                                    child: const Text("Next 7 Days")),
                                RadioMenuButton(
                                    value: TaskListModes.upcoming,
                                    groupValue: vm.mode,
                                    onChanged: (value) =>
                                        vm.configure(mode: value),
                                    child: const Text("Upcoming")),
                              ],
                              child: Text(
                                "Mode",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            MenuItemButton(
                              onPressed: () =>
                                  vm.configure(showOverdue: !vm.showOverdue),
                              leadingIcon: Icon(vm.showOverdue
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded),
                              child: const Text("Show Overdue"),
                            ),
                            MenuItemButton(
                              onPressed: () => vm.configure(
                                  showCompleted: !vm.showCompleted),
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
                          ))
                    ]),
                body: RefreshIndicator(
                    onRefresh: vm.onRefresh,
                    child: ListView(
                        shrinkWrap: false,
                        physics: const ClampingScrollPhysics(),
                        children: [
                          // Widget for Overdue tasks
                          vm.showOverdue && overdue.isNotEmpty
                              ? ExpansionTile(
                                  title: Text(
                                    "Overdue",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  initiallyExpanded: true,
                                  children: [
                                      ...overdue
                                          .map((e) => TaskListItemWidget(e, vm))
                                    ])
                              : const SizedBox.shrink(),
                          // Widget for today's tasks
                          today.isNotEmpty
                              ? ListView(
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        "${formatDate(tod)} \u2022 ${vm.mode == TaskListModes.today ? getWeekday(tod) : "Today \u2022 ${getWeekday(tod)}"}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                    ...today
                                        .map((e) => TaskListItemWidget(e, vm)),
                                  ],
                                )
                              : vm.mode == TaskListModes.today
                                  ? ListTile(
                                      title: Text("Nothing due today",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall),
                                    )
                                  : const SizedBox.shrink(),
                          vm.mode != TaskListModes.today && upcoming.isNotEmpty
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
                                      titleStr =
                                          "$dateStr \u2022 Tomorrow \u2022 $weekday";
                                    } else {
                                      titleStr = "$dateStr \u2022  $weekday";
                                    }

                                    String subtitle =
                                        "${upcoming.length} tasks due";

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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                          subtitle: Text(
                                            subtitle,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          trailing: IconButton(
                                              onPressed: () {
                                                TaskModel model =
                                                    TaskModel.createEmpty();
                                                model.updateDeadline(date);
                                                openEditTaskModal(
                                                        model, vm, context)
                                                    .then(
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
                                        ...dayTasks.map(
                                            (e) => TaskListItemWidget(e, vm)),
                                        div,
                                      ],
                                    );
                                  },
                                )
                              : const SizedBox.shrink(),
                          vm.showCompleted && completed.isNotEmpty
                              ? ExpansionTile(
                                  title: Text(
                                    "Completed",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  initiallyExpanded: false,
                                  children: [
                                    ...completed.map((e) => TaskListItemWidget(
                                          e,
                                          vm,
                                          showCheckbox: false,
                                        ))
                                  ],
                                )
                              : const SizedBox.shrink()
                        ])),
                floatingActionButton: FloatingActionButton(
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
                ));
          },
        ));
  }
}
