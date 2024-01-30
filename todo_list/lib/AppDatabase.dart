import 'dart:async';
import 'package:floor/floor.dart';
import 'package:todo_list/data/TaskData.dart';

import 'package:sqflite/sqflite.dart' as sqflite;

part 'AppDatabase.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Task])
abstract class AppDatabase extends FloorDatabase {
  static const databaseName = "tasklist_app.db";
  TaskDao get taskDao;
}
