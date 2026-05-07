import 'package:floor/floor.dart';
import 'package:todo_list/date_utils.dart';

/// Classes/data for relational representation of a task, accessing tasks in database
@Entity(tableName: Task.tableName)
class Task {
  Task(
      this.id, this.title, this.description, this.deadline, this.completedDate, this.repeatPattern);

  @ignore
  static const tableName = "task";

  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String title;
  final String description;
  final DateTime deadline;
  final DateTime? completedDate; // optional field for completion
  final String repeatPattern;
  Task.create(this.title, this.description, this.deadline)
      : id = null,
        completedDate = null,
        repeatPattern = "";

  Task.createEmpty()
      : id = null,
        title = "",
        description = "",
        deadline = TaskListDateUtils.today(),
        completedDate = null,
        repeatPattern = "";
}

@dao
abstract class TaskDao {
  @Query("SELECT * FROM ${Task.tableName}")
  Future<List<Task>> list();

  @Query("SELECT * FROM ${Task.tableName} WHERE title = :title")
  Future<Task?> getByTitle(String title);

  @Query("DELETE FROM ${Task.tableName} WHERE id = :id")
  Future<void> delete(int id);


  @Query("SELECT * FROM ${Task.tableName} WHERE completedDate IS NULL ORDER BY deadline DESC")
  Future<List<Task>> getIncomplete();

  @Query(
      "SELECT * FROM ${Task.tableName} WHERE completedDate IS NOT NULL ORDER BY deadline DESC")
  Future<List<Task>> getComplete();

  @insert
  Future<void> insertOne(Task task);

  @insert
  Future<List<int>> insertAll(List<Task> tasks);

  @update
  Future<void> updateOne(Task task);
}
