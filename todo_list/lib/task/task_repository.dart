import 'package:todo_list/database/tables/task.dart';
import 'package:todo_list/task/task_model.dart';

class TaskRepository {
   final TaskDao _taskDao;

  TaskRepository(this._taskDao);

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

      toInsert.add(Task(null, task.title, task.description, task.deadline, task.completedDate));
    }
    return _taskDao.insertAll(toInsert);
  }

  Future<void> insertTask(TaskModel task) {
    return _taskDao.insertOne(Task(task.id, task.title, task.description, task.deadline, task.completedDate));
  }

  Future<void> deleteTask(int id) {
    return _taskDao.delete(id);
  }

  Future<void> updateTask(TaskModel task) {
    return _taskDao.updateOne(Task(task.id, task.title, task.description, task.deadline, task.completedDate));
  }
}
