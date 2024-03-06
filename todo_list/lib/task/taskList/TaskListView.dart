import 'dart:core';

import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
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

  List<TaskModel> _overdue = [];
  List<TaskModel> _today = [];
  final List<TaskModel> _tomorrow = [];
  Map<DateTime, List<TaskModel>> _upcoming = {};
  List<DateTime> _taskDays = [];
  List<TaskModel> _completed = [];

  String get screenName => widget.screenName;

  // main components of screen
  final MenuController _overflowController = MenuController();

  TaskListView();

  @override
  void initState() {
    super.initState();
    _vm = TaskListVM(screenName);
    _vm.getAllTasks();
  }

  void _update() {
    DateTime tod = DateTimeConverter.today();
    if (_vm.showOverdue) {
      _overdue = _vm.getOverdue();
    }
    if (_vm.showCompleted) {
      _completed = _vm.getComplete();
      _completed.sort(
        (a, b) => compareDates(a.deadline, b.deadline),
      );
    }
    _today = _vm.getToday();
    if (_vm.mode != TaskListModes.today) {
      _upcoming = _vm.getUpcoming();
    }

    _taskDays = _upcoming.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    _update();
    DateTime tod = DateTimeConverter.today();

    return ChangeNotifierProvider(
        create: (_) => _vm,
        child: Consumer<TaskListVM>(
          builder: (context, value, child) {
            return Scaffold(
                appBar: AppBar(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
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
                                    onChanged: (value) =>
                                        _vm.configure(mode: value),
                                    child: const Text("Today")),
                                RadioMenuButton(
                                    value: TaskListModes.week,
                                    groupValue: _vm.mode,
                                    onChanged: (value) =>
                                        _vm.configure(mode: value),
                                    child: const Text("Next 7 Days")),
                                RadioMenuButton(
                                    value: TaskListModes.upcoming,
                                    groupValue: _vm.mode,
                                    onChanged: (value) =>
                                        _vm.configure(mode: value),
                                    child: const Text("Upcoming")),
                              ],
                              child: Text(
                                "Mode",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            MenuItemButton(
                              onPressed: () =>
                                  _vm.configure(showOverdue: !_vm.showOverdue),
                              leadingIcon: Icon(_vm.showOverdue
                                  ? Icons.check_box_rounded
                                  : Icons.check_box_outline_blank_rounded),
                              child: const Text("Show Overdue"),
                            ),
                            MenuItemButton(
                              onPressed: () => _vm.configure(
                                  showCompleted: !_vm.showCompleted),
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
                            MenuItemButton(child: Text("LogOut"), onPressed: () => Amplify.Auth.signOut(),)
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
                    onRefresh: _vm.onRefresh,
                    child: ListView(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        children: [
                          // Widget for Overdue tasks
                          _vm.showOverdue && _overdue.isNotEmpty
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
                                      ..._overdue.map(
                                          (e) => TaskListItemWidget(e, _vm))
                                    ])
                              : const SizedBox.shrink(),
                          // Widget for today's tasks
                          _today.isNotEmpty
                              ? ListView(
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        "${formatDate(tod)} \u2022 ${_vm.mode == TaskListModes.today ? getWeekday(tod) : "Today \u2022 ${getWeekday(tod)}"}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                    ..._today
                                        .map((e) => TaskListItemWidget(e, _vm)),
                                    const Divider(
                                      height: 5,
                                      thickness: 5,
                                      indent: 0,
                                      endIndent: 0,
                                    )
                                  ],
                                )
                              : const SizedBox.shrink(),
                          _vm.mode != TaskListModes.today && _upcoming.isNotEmpty ?
                          ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _taskDays.length,
                            itemBuilder: (context, index) {
                              DateTime date = _taskDays[index];
                              List<TaskModel> dayTasks = _upcoming[date]!;

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

                              String subtitle = "${_upcoming.length} tasks due";

                              if (_upcoming.isEmpty) {
                                subtitle = "No tasks due";
                              } else if (_upcoming.length == 1) {
                                subtitle = "${_upcoming.length} task due";
                              }
                              return ListView(
                                physics: const ClampingScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  ListTile(
                                    title: Text(
                                      titleStr,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
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
                                          openEditTaskModal(model, _vm, context)
                                              .then(
                                            (value) {
                                              if (value != null) {
                                                _vm.addTask(value);
                                              }
                                              _vm.onModalClose();
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.add)),
                                  ),
                                  ...dayTasks
                                      .map((e) => TaskListItemWidget(e, _vm)),
                                  const Divider(
                                    height: 5,
                                    thickness: 5,
                                    indent: 0,
                                    endIndent: 0,
                                  )
                                ],
                              );
                            },
                          ): const SizedBox.shrink(),
                          _vm.showCompleted && _completed.isNotEmpty
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
                                    ..._completed
                                        .map((e) => TaskListItemWidget(e, _vm))
                                  ],
                                )
                              : const SizedBox.shrink()
                        ])),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    TaskModel task = TaskModel.createEmpty();
                    openEditTaskModal(task, _vm, context).then(
                      (value) {
                        if (value != null) {
                          _vm.addTask(value);
                        }
                        _vm.onModalClose();
                      },
                    );
                  },
                  child: const Icon(Icons.add),
                ));
          },
        ));
  }
}
