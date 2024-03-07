import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/di.dart';
import 'package:todo_list/task/task_repository.dart';
import 'package:todo_list/task/taskList/TaskList.dart';
import 'package:todo_list/tasklist_auth.dart';

import 'user_repository.dart';


Future<void> main() async{

  return runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await configureDependencies();
    runApp(const MyApp());
  }, (error, stack) {
    safePrint(stack);
    safePrint(error);
  });

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
    return Authenticator(child: MaterialApp(
          title: 'Flutter Demo',
          builder: Authenticator.builder(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white10,
                brightness: Brightness.dark),
            useMaterial3: true,
          ),
          home: const TaskList(),
        ));
  }

  @override
  void initState() {
    super.initState();
    getIt.getAsync<TaskListAuth>().then((value) => value.init(),);

  }


}
