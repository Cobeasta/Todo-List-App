import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/Settings.dart';
import 'package:todo_list/amplifyconfiguration.dart';
import 'package:todo_list/database/tables/Task.dart';
import 'package:todo_list/database/AppDatabase.dart';
import 'package:todo_list/task/TaskRepository.dart';
import 'package:todo_list/task/taskList/TaskList.dart';
import 'package:todo_list/tasklist_auth.dart';

final getIt = GetIt.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerSingletons();
  runApp(const MyApp());
}


void registerSingletons() {
  // auth


  // shared prefs
  getIt.registerSingletonAsync<Settings>(() async {
    return Settings(await SharedPreferences.getInstance());
  });

  // database
  getIt.registerSingletonAsync(() async => $FloorAppDatabase
      .databaseBuilder(AppDatabase.databaseName).build());

  getIt.registerSingletonWithDependencies<TaskDao>(() {
    return getIt.get<AppDatabase>().taskDao;
  }, dependsOn: [AppDatabase]);
  getIt.registerSingletonWithDependencies<TaskRepository>(
      () => TaskRepository(),
      dependsOn: [TaskDao]);

  // view model for a task
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();

  // This widget is the root of your application.

}
class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      initialStep: AuthenticatorStep.signIn,
        child: MaterialApp(
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
    TaskListAuthUtils.init();

  }


}
