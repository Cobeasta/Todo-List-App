import 'dart:async';
import 'package:floor/floor.dart';
import 'package:injectable/injectable.dart';
import 'package:todo_list/database/tables/task.dart';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';

part 'AppDatabase.g.dart'; // the generated code will be there

@TypeConverters([DateTimeConverter, OptionalDateTimeConverter])
@Database(version: 1, entities: [Task])
abstract class AppDatabase extends FloorDatabase {
  static const databaseName = "tasklist_app.db";

  TaskDao get taskDao;
}

@module
abstract class RegisterModule {

  @singleton
  Future<AppDatabase> get appDatabase =>
      $FloorAppDatabase.databaseBuilder(AppDatabase.databaseName).build();

  @singleton
  Future<TaskDao> get taskDao async => (await appDatabase).taskDao;
}
