import 'package:flutter/material.dart';
import 'package:todo_list/task/taskList/TaskListView.dart';

class TaskList extends StatefulWidget {
  final String _title;
  get title => _title;
  const TaskList(this._title, {super.key});
  @override
  State<StatefulWidget> createState() =>  TaskListView();
}