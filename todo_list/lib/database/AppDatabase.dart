import 'dart:async';
import 'package:floor/floor.dart';
import 'package:todo_list/database/tables/Task.dart';
import 'package:todo_list/database/tables/TaskLabel.dart';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';

part 'AppDatabase.g.dart'; // the generated code will be there

/**
 * To generate code for app database daos, run `dart run build_runner build`
 * To continuously update `dart run build_runner watch`
 *
 */
@TypeConverters([DateTimeConverter, OptionalDateTimeConverter])
@Database(version: 1, entities: [Task, TaskLabel])
abstract class AppDatabase extends FloorDatabase {
  static const databaseName = "tasklist_app.db";
  TaskDao get taskDao;
  TasklabelDao get taskLabelDao;

}

