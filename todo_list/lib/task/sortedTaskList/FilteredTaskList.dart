import 'package:flutter/material.dart';
import 'package:todo_list/task/sortedTaskList/FilteredTaskListView.dart';

class FilteredTaskList extends StatefulWidget {
  final String _title;
  get title => _title;
  const FilteredTaskList(this._title, {super.key});
  @override
  State<StatefulWidget> createState() =>  FilteredTaskListView();
}