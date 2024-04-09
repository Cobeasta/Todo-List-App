import 'dart:async';
import 'package:floor/floor.dart';
import 'package:todo_list/database/tables/task.dart';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:todo_list/database/typeConverters/date_time_converter.dart';

part 'AppDatabase.g.dart'; // the generated code will be there

@TypeConverters([DateTimeConverter, OptionalDateTimeConverter])
@Database(version: 1, entities: [Task])
abstract class AppDatabase extends FloorDatabase {
  static const databaseName = "tasklist_app.db";

  TaskDao get taskDao;
}