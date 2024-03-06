import 'package:todo_list/database/tables/task.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/task/TaskModel.dart';
import 'package:todo_list/tasklist_auth.dart';

class TaskRepository {
   TaskDao _taskDao;
   TaskListAuth _auth;

  TaskRepository(this._taskDao, this._auth) {
    _taskDao = getIt.get<TaskDao>();
  }

  Future<List<TaskModel>> listTasks() async {
    List<Task> tasks = await _taskDao.list(_auth.localUserId);
    List<TaskModel> result = [];
    for (var task in tasks) {
      result.add(TaskModel(task));
    }
    return result;
  }

  Future<List<TaskModel>> listTasksFilterByCompletion(bool isComplete) async {
    List<Task> tasks;
    if (!isComplete) {
      tasks = await _taskDao.getIncomplete(_auth.localUserId);
    } else {
      tasks = await _taskDao.getIncomplete(_auth.localUserId);
    }
    List<TaskModel> result = [];
    result.addAll(tasks.map<TaskModel>((task) => TaskModel(task)));
    return result;
  }

  Future<List<int>> insertTaskList(List<TaskModel> tasks) {
    List<Task> toInsert = [];
    for (var task in tasks) {

      toInsert.add(Task(null, task.title, task.description, task.deadline, task.completedDate, _auth.localUserId));
    }
    return _taskDao.insertAll(toInsert);
  }

  Future<void> insertTask(TaskModel task) {
    return _taskDao.insertOne(Task(task.id, task.title, task.description, task.deadline, task.completedDate, _auth.localUserId));
  }

  Future<void> deleteTask(int id) {
    return _taskDao.delete(id, _auth.localUserId);
  }

  Future<void> updateTask(TaskModel task) {
    return _taskDao.updateOne(Task(task.id, task.title, task.description, task.deadline, task.completedDate, _auth.localUserId));
  }
}
