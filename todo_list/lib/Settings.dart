import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/task/taskList/task_list_vm.dart';


class Settings {
  SharedPreferences prefs;

  Settings(this.prefs);

  bool initialized = false;

  bool? _taskListShowOverdue;
  int? _taskListMode;
  bool? _taskListShowCompleted;

  // Get configuration settings
  bool get taskListShowOverdue {
    _taskListShowOverdue ??= prefs.getBool("TaskListShowOverdue");
    if (_taskListShowOverdue == null) {
      _taskListShowOverdue = true;
      prefs.setBool("TaskListShowOverdue", true);
    }
    return _taskListShowOverdue!;
  }

  TaskListModes get taskListMode {
    _taskListMode ??= prefs.getInt("TaskListMode");
    if (_taskListMode == null) {
      _taskListMode = TaskListModes.today.value;
      prefs.setInt("TaskListMode", _taskListMode!);
    }
    return TaskListModes.values
        .firstWhere((element) => element.value == _taskListMode!);
  }

  bool get taskListShowCompleted {
    _taskListShowCompleted ??= prefs.getBool("TaskListShowCompleted");
    if (_taskListShowCompleted == null) {
      _taskListShowCompleted = false;
      prefs.setBool("TaskListShowCompleted", _taskListShowCompleted!);
    }
    return _taskListShowCompleted!;
  }

  // Setters

  set taskListShowOverdue(bool value) {
    prefs.setBool("TaskListShowOverdue", value);
    _taskListShowOverdue = value;
  }

  set taskListMode(TaskListModes mode) {
    prefs.setInt("TaskListMode", mode.value);
    _taskListMode = mode.value;
  }

  set taskListShowCompleted(bool value) {
    prefs.setBool("TaskListShowCompleted", value);
    _taskListShowCompleted = value;
  }
}
