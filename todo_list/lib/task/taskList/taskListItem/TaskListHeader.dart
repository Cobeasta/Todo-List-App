

import 'package:flutter/material.dart';

class TaskListHeader extends StatelessWidget {
  final String _title;
  final Key _key = UniqueKey();

  TaskListHeader(this._title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(child:Text(
      _title,
      style: Theme.of(context).textTheme.headlineSmall,
      key: _key,
    ));
  }
}