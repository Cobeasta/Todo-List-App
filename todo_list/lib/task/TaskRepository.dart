import 'package:todo_list/database/tables/Task.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/task/TaskModel.dart';

class TaskRepository {
  late TaskDao _taskDao;

  TaskRepository() {
    _taskDao = getIt.get<TaskDao>();
  }

  Future<List<TaskModel>> listTasks() async {
    List<Task> tasks = await _taskDao.list();
    List<TaskModel> result = [];
    for (var task in tasks) {
      result.add(TaskModel(task));
    }
    return result;
  }

  Future<List<TaskModel>> listTasksFilterByCompletion(bool isComplete) async {
    List<Task> tasks;
    if (!isComplete) {
      tasks = await _taskDao.getIncomplete();
    } else {
      tasks = await _taskDao.getIncomplete();
    }
    List<TaskModel> result = [];
    result.addAll(tasks.map<TaskModel>((task) => TaskModel(task)));
    return result;
  }

  Future<List<int>> insertTaskList(List<TaskModel> tasks) {
    List<Task> toInsert = [];
    for (var task in tasks) {
      toInsert.add(task.getData());
    }
    return _taskDao.insertAll(toInsert);
  }

  Future<void> insertTask(TaskModel task) {
    return _taskDao.insertOne(task.getData());
  }

  Future<void> deleteTask(int id) {
    return _taskDao.delete(id);
  }

  Future<void> updateTask(TaskModel task) {
    return _taskDao.updateOne(task.getData());
  }
}
