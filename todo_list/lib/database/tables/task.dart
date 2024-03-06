import 'package:floor/floor.dart';
import 'package:todo_list/database/tables/user.dart';
import 'package:todo_list/database/tables/user_protected_table.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';
import 'package:todo_list/tasklist_auth.dart';
import 'package:todo_list/task/TaskModel.dart';

/// Classes/data for relational representation of a task, accessing tasks in database
@Entity(tableName: Task.tableName, foreignKeys: [
  UserProtectedTableBase.userForeignKey
])
class Task extends UserProtectedTableBase{
  Task(
      this.id, this.title, this.description, this.deadline, this.completedDate, super.userId);

  @ignore
  static const tableName = "task";

  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String title;
  final String description;
  final DateTime deadline;
  final DateTime? completedDate; // optional field for completion

  Task.create(this.title, this.description, this.deadline, super.userId)
      : id = null,
        completedDate = null;

  Task.createEmpty(super.userId)
      : id = null,
        title = "",
        description = "",
        deadline = DateTimeConverter.today(),
        completedDate = null;
}

@dao
abstract class TaskDao {
  @Query('SELECT * FROM ${Task.tableName} WHERE ${UserProtectedTableBase.userTableFilter}')
  Future<List<Task>> list(int uid);

  @Query("SELECT * FROM ${Task.tableName} WHERE title = :title AND ${UserProtectedTableBase.userTableFilter}")
  Future<Task?> getByTitle(String title, int uid);

  @Query("DELETE FROM ${Task.tableName} WHERE id = :id AND ${UserProtectedTableBase.userTableFilter}")
  Future<void> delete(int id, int uid);

  @Query(
      "SELECT FROM ${Task.tableName} WHERE isComplete IS NOT NULL AND ${UserProtectedTableBase.userTableFilter} ORDER BY isComplete DESC")
  Future<List<Task>> getIncomplete(int uid);

  @Query(
      "SELECT FROM ${Task.tableName} WHERE isComplete IS NULL AND ${UserProtectedTableBase.userTableFilter} ORDER BY isComplete DESC")
  Future<List<Task>> getComplete(int uid);

  @insert
  Future<void> insertOne(Task task);

  @insert
  Future<List<int>> insertAll(List<Task> tasks);

  @update
  Future<void> updateOne(Task task);
}
