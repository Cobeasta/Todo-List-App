import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/basic_widgets/task_list_checkbox.dart';
import 'package:todo_list/date_utils.dart';

import 'task_list_item.dart';
import 'task_list_item_vm.dart';


class TaskItemView extends State<TaskListItemWidget> {
  late TaskListItemVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = TaskListItemVM(widget.model, widget.taskListVM);
  }

  Widget buildCheckbox(BuildContext context) {
    return TaskListCheckBox(_vm.isComplete, (val) => _vm.onCheckToggle(val));
  }

  Widget buildTitle(BuildContext context) {
    return Text(
      _vm.title,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  Widget buildSubtitle(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_month_outlined),
        Text(
          TaskListDateUtils.formatDate(_vm.deadline),
          style: Theme.of(context).textTheme.bodyMedium,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskListItemVM>(
      create: (context) => _vm,
      child: Consumer<TaskListItemVM>(
        builder: (context, tvm, child) {
          return Card(
            child: ListTile(
              leading: widget.showCheckbox ? buildCheckbox(context) : null,
              title: buildTitle(context),
              subtitle: buildSubtitle(context),
              onTap: () => tvm.onTap(context),
            ),
          );
        },
      ),
    );
  }
}
