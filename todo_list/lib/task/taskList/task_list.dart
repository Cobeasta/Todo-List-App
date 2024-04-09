import 'package:flutter/material.dart';
import 'package:todo_list/task/taskList/task_list_view.dart';


class TaskList extends StatefulWidget {
  final String screenName = "TaskList";


  const TaskList({super.key});
  @override
  State<StatefulWidget> createState() => TaskListView();
}