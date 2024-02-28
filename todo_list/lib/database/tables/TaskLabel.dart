import 'package:floor/floor.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';

import 'Task.dart';

/// Classes/data for relational representation of a task, accessing tasks in database
@Entity(
    tableName: TaskLabel.tableName,
    primaryKeys: ['id', ''],
    foreignKeys: [
      ForeignKey(
          childColumns: ['task_id'],
          parentColumns: ['id'],
          entity: Task)
    ])
class TaskLabel {
  @ignore
  static const tableName = "task_label";

  TaskLabel(this.id, this.task_id, this.name);

  final int? id;
  @ColumnInfo(name: "task_id")
  final int? task_id;
  final String name;


  TaskLabel.create(this.name)
      : id = null,
        task_id = null;

  TaskLabel.createEmpty()
      : id = null,
  task_id = null,
        name = "";
}

@dao
abstract class TasklabelDao {
  @Query('SELECT * FROM ${TaskLabel.tableName}')
  Future<List<Task>> list();

  @Query("SELECT * FROM ${TaskLabel.tableName} WHERE name = :name")
  Future<Task?> getByName(String name);

  @Query("DELETE FROM ${TaskLabel.tableName} WHERE id = :id")
  Future<void> delete(int id);

  @insert
  Future<void> insertOne(TaskLabel label);

  @insert
  Future<List<int>> insertAll(List<TaskLabel> labels);

  @update
  Future<void> updateOne(TaskLabel task);
}
