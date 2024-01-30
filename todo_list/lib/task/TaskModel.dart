import 'package:flutter/material.dart';
import 'package:todo_list/data/TaskData.dart';

class TaskModel {
  TaskModel(Task task)
      : _id = task.id,
        _title = task.title == null ? "" : task.title!,
        _description = task.description == null ? "" : task.description!,
        _isCompleted = task.isComplete == null ? false : task.isComplete!;

  TaskModel.createEmpty()
      : _id = null,
        _title = "",
        _description = "",
        _isCompleted = false;

  final int? _id;
  String _title;
  String _description;
  bool _isCompleted;

  get title => _title;

  get description => _description;

  get isComplete => _isCompleted;

  get id => _id;

  void updateTitle(String text) {
    _title = text;
  }

  void updateDescription(String text) {
    _description = text;
  }

  /**
   * Change value of isComplete.
   */
  void setComplete(bool? value) {
    if (value == null) {
      _isCompleted = !_isCompleted;
    } else if (value != _isCompleted) {
      _isCompleted = value;
    } else {
      return;
    }
    // _isCompleted did change
  }

  Task getData() {
    return Task(_id, _title, _description, _isCompleted);
  }

  @override
  bool operator ==(Object other) {
    if (other is TaskModel) {
      if (_id != null && other.id != null) {
        return _id == other.id;
      }
      return _title == other.title;
    }
    return false;
  }

  @override
  int get hashCode => _id.hashCode;
}
