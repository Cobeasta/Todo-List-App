import 'package:floor/floor.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';

/// Classes/data for relational representation of a task, accessing tasks in database
@Entity(tableName: Task.tableName)
class Task {
  Task(this.id, this.title, this.description, this.deadline, this.completedDate);

  @ignore
  static const tableName = "task";

  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String title;
  final String description;
  final DateTime deadline;
  final DateTime? completedDate; // optional field for completion

  Task.create(this.title, this.description, this.deadline)
      : id = null,
        completedDate = null;

  Task.createEmpty()
      : id = null,
        title = "",
        description = "",
        deadline = DateTimeConverter.today(),
        completedDate = null;
}

@dao
abstract class TaskDao {
  @Query('SELECT * FROM ${Task.tableName}')
  Future<List<Task>> list();

  @Query("SELECT * FROM ${Task.tableName} WHERE title = :title")
  Future<Task?> getByTitle(String title);

  @Query("DELETE FROM ${Task.tableName} WHERE id = :id")
  Future<void> delete(int id);

  @Query("SELECT FROM ${Task.tableName} WHERE isComplete IS NOT NULL ORDER BY isComplete DESC")
  Future<List<Task>> getIncomplete();
  @Query("SELECT FROM ${Task.tableName} WHERE isComplete IS NULL ORDER BY isComplete DESC")
  Future<List<Task>> getComplete();

  @insert
  Future<void> insertOne(Task task);

  @insert
  Future<List<int>> insertAll(List<Task> tasks);

  @update
  Future<void> updateOne(Task task);
}
