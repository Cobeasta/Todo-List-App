import 'package:todo_list/data/TaskData.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/task/TaskModel.dart';

class TaskRepository {
  late TaskDao _taskDao;

  TaskRepository() {
    _taskDao = getIt.get<TaskDao>();
  }

  Future<List<TaskModel>> listTasks() async {
    List<Task> tasks = await _taskDao.listTasks();
    List<TaskModel> result = [];
    for (var task in tasks) {
      result.add(TaskModel(task));
    }
    return result;
  }

  Future<List<TaskModel>> listTasksFilterByStatus(bool isComplete) async {
    List<Task> tasks = await _taskDao.getTaskFilterByIsComplete(isComplete);
    List<TaskModel> result = [];
    result.addAll(tasks.map<TaskModel>((task) => TaskModel(task)));
    return result;
  }

  Future<List<int>> insertTaskList(List<TaskModel> tasks) {
    List<Task> toInsert = [];
    for (var task in tasks) {
      toInsert.add(task.getData());
    }
    return _taskDao.insertAllTasks(toInsert);
  }

  Future<void> insertTask(TaskModel task) {
    return _taskDao.insertTask(task.getData());
  }

  Future<void> deleteTask(int id) {
    return _taskDao.deleteTask(id);
  }

  Future<void> updateTask(TaskModel task) {
    return _taskDao.updateTask(task.getData());
  }
}
