import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo_list/di.dart';
import 'package:todo_list/task/task_repository.dart';
import 'package:todo_list/task/taskList/TaskList.dart';

Future<void> main() async {
  return runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await configureDependencies();
    runApp(const MyApp());
  }, (error, stack) {});
}

/*
void registerSingletons() {
  // auth


  // shared prefs
  getIt.registerSingletonAsync<Settings>(() async {
    return Settings(await SharedPreferences.getInstance());
  });

  // database
  getIt.registerSingletonAsync(() async => $FloorAppDatabase
      .databaseBuilder(AppDatabase.databaseName).build());


  getIt.registerSingletonWithDependencies<UserDao>(() {
    return getIt.get<AppDatabase>().userDao;
  }, dependsOn: [AppDatabase]);

  getIt.registerSingletonWithDependencies<UserRepository>(() {
    return UserRepository(getIt.get<UserDao>());
  }, dependsOn: [UserDao]);
  // Auth singleton
  getIt.registerSingletonWithDependencies<TaskListAuth>(() {
    return TaskListAuth(getIt.get<UserRepository>());
  }, dependsOn: [UserRepository]);


  // Tasks
  getIt.registerSingletonWithDependencies<TaskDao>(() {
    return getIt.get<AppDatabase>().taskDao;
  }, dependsOn: [AppDatabase]);

  getIt.registerSingletonWithDependencies<TaskRepository>(
      () => TaskRepository(getIt.get<TaskDao>(), getIt.get<TaskListAuth>()),
      dependsOn: [TaskDao, TaskListAuth]);

  // view model for a task
}*/

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();

// This widget is the root of your application.
}

class _MyAppState extends State<MyApp> {
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

  @override
  void initState() {
    super.initState();
  }
}
