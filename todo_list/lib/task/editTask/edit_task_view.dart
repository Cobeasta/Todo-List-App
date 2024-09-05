import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/basic_widgets/task_list_checkbox.dart';
import 'package:todo_list/date_utils.dart';
import 'package:todo_list/task/task_model.dart';
import 'package:todo_list/task/taskList/task_list_vm.dart';
import 'edit_task_modal.dart';
import 'edit_task_vm.dart';

class EditTaskModalView extends State<EditTaskModal> {
  late EditTaskVM _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = EditTaskVM(widget.taskListVM, widget.task);
    _viewmodel.init();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("EditTaskView build");
    }
    return ChangeNotifierProvider<EditTaskVM>.value(
        value: _viewmodel,
        child: Consumer<EditTaskVM>(
          builder: (context, vm, child) {
            return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDateHeaderRow(context, vm),
                      _buildTextfieldItems(context, vm),
                      _buildItemModButtons(context, vm)
                    ]));
          },
        ));
  }

  Widget _buildDateHeaderRow(BuildContext context, EditTaskVM vm) {
    DateTime in2Days = TaskListDateUtils.daysFromToday(2);
    DateTime weekend = TaskListDateUtils.thisSaturday();
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            vm.updateDeadline(TaskListDateUtils.today());
          },
          child: const Text("Tod"),
        ),
        ElevatedButton(
          onPressed: () {
            vm.updateDeadline(TaskListDateUtils.tomorrow());
          },
          child: const Text("Tom"),
        ),
        ElevatedButton(
          onPressed: () {
            vm.updateDeadline(in2Days);
          },
          child: Text(TaskListDateUtils.getWeekday(in2Days)),
        ),
        Spacer(),
        TaskListDateUtils.today().weekday < 6
            ? Card(
                child: IconButton(
                    onPressed: () {
                      vm.updateDeadline(weekend);
                    },
                    icon: const Icon(Icons.weekend)),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildItemModButtons(BuildContext context, EditTaskVM vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: () {
              _buildSelectDatePopup(context, vm);
            },
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined),
                Text(TaskListDateUtils.formatDate(vm.deadline)),
              ],
            )),
        IconButton(
            onPressed: () {
              vm.delete(context);
            },
            icon: const Icon(Icons.delete)),
        IconButton(
            onPressed: () {
              vm.submit(context);
            },
            icon: const Icon(Icons.send)),
      ],
    );
  }

  Widget _buildTextfieldItems(BuildContext context, EditTaskVM vm) {
    return Column(
      children: [
        _buildFormItem(context,
            leading: TaskListCheckBox(
                vm.isCompleted, (val) => vm.onCheckToggle(context, val)),
            child: Expanded(
                child: TextField(
              decoration: const InputDecoration(
                hintText: "Task Title",
              ),
              autofocus: (vm.title == ""),
              controller: vm.titleController,
            ))),
        _buildFormItem(context,
            leading:
                Transform.scale(scale: 1.3, child: const Icon(Icons.edit_note)),
            child: Expanded(
                child: TextField(
              decoration: const InputDecoration(
                hintText: "Description",
              ),
              controller: vm.descriptionController,
              style: Theme.of(context).textTheme.bodyLarge,
            )))
      ],
    );
  }

  void _buildSelectDatePopup(BuildContext context, EditTaskVM vm) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: TaskListDateUtils.today(),
      firstDate: TaskListDateUtils.today(),
      lastDate: DateTime(DateTime.timestamp().year + 5),
    );
    if (picked == null) {
      vm.updateDeadline(TaskListDateUtils.today());
    } else {
      vm.updateDeadline(picked);
    }
  }

  Widget _buildFormItem(BuildContext context,
      {Widget? leading, required Widget child}) {
    return Card(
        child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      textBaseline: TextBaseline.ideographic,
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.only(right: 10),
          child: leading ?? const SizedBox.square(),
        ),
        child
      ],
    ));
  }
}

Future<dynamic> openEditTaskModal(
    TaskModel task, TaskListVM taskListVM, BuildContext context) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return EditTaskModal(task, taskListVM);
      });
}
