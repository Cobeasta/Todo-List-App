import 'dart:async';
import 'package:floor/floor.dart';
import 'package:todo_list/database/tables/task.dart';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:todo_list/database/typeConverters/date_time_converter.dart';

part 'app_database.g.dart'; // the generated code will be there

@TypeConverters([DateTimeConverter, OptionalDateTimeConverter])
@Database(version: 2, entities: [Task])
abstract class AppDatabase extends FloorDatabase {
  static const databaseName = "tasklist_app.db";

  TaskDao get taskDao;
}
final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('''
      ALTER TABLE ${Task.tableName}
        ADD COLUMN repeatPattern TEXT NOT NULL DEFAULT ''
    ''');
});
