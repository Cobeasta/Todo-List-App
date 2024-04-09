import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/database/AppDatabase.dart';
import 'package:todo_list/database/tables/task.dart';
import 'package:todo_list/task/taskList/TaskList.dart';
import 'package:todo_list/task/task_repository.dart';

import 'Settings.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerSingletons();
  runApp(const MyApp());
}

void registerSingletons() {
  // shared prefs
  getIt.registerSingletonAsync<Settings>(() async {
    return Settings(await SharedPreferences.getInstance());
  });

  // database
  getIt.registerSingletonAsync(() async =>
      $FloorAppDatabase.databaseBuilder(AppDatabase.databaseName).build());

  getIt.registerSingletonWithDependencies<TaskDao>(() {
    return getIt.get<AppDatabase>().taskDao;
  }, dependsOn: [AppDatabase]);
  getIt.registerSingletonWithDependencies<TaskRepository>(
      () => TaskRepository(getIt.get<TaskDao>()),
      dependsOn: [TaskDao]);

  // view model for a task
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white10, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const TaskList(),
    );
  }

// This widget is the root of your application.
}
