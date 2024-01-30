import 'package:floor/floor.dart';

/// Classes/data for relational representation of a task, accessing tasks in database
@Entity(tableName: Task.tableName)
class Task {
  Task(this.id, this.title, this.description, this.isComplete);

  static const tableName = "task_list";
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String? title;
  final String? description;
  final bool? isComplete;

  Task.create(this.title, this.description, this.isComplete) : id = null;

  Task.createEmpty()
      : id = null,
        title = "",
        description = "",
        isComplete = false;
}
@dao
abstract class TaskDao {
  @Query('SELECT * FROM task_list')
  Future<List<Task>> listTasks();

  @Query("SELECT * FROM ${Task.tableName} WHERE title = :title")
  Future<Task?> getTaskByTitle(String title);

  @Query("DELETE FROM ${Task.tableName} WHERE id = :id")
  Future<void> deleteTask(int id);

  @Query("SELECT FROM ${Task.tableName} WHERE isComplete = :status")
  Future<List<Task>> getTaskFilterByIsComplete(bool status);

  @insert
  Future<void> insertTask(Task task);

  @insert
  Future<List<int>> insertAllTasks(List<Task> tasks);

  @update
  Future<void> updateTask(Task task);
}


