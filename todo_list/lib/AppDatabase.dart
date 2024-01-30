import 'dart:async';
import 'package:floor/floor.dart';
import 'package:todo_list/data/TaskData.dart';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

part 'AppDatabase.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Task])
abstract class AppDatabase extends FloorDatabase {
  static const databaseName = "tasklist_app.db";
  TaskDao get taskDao;
}

/*class DatabaseProvider {
  static final _instance = DatabaseProvider._internal();

  static get instance => _instance;

  bool isInitialized = false;
  late Database _db;

  DatabaseProvider._internal();

  Future<Database> db() async {
    if (!isInitialized) await _init();
    return _db;
  }

  Future _init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "todo_list.db");
    _db = await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
      await db.execute(TaskDao().createTableQueryString);
    });
  }
}*/
