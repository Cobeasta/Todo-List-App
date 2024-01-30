import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_list/data/TaskData.dart';
import 'package:todo_list/AppDatabase.dart';
import 'package:todo_list/task/TaskRepository.dart';
import 'package:todo_list/task/sortedTaskList/FilteredTaskList.dart';


final getIt = GetIt.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerSingletons();
  runApp(const MyApp());
}

void registerSingletons() {
   getIt.registerSingletonAsync(() async =>$FloorAppDatabase.databaseBuilder(AppDatabase.databaseName).build());

   getIt.registerSingletonWithDependencies<TaskDao>(() {
     return getIt.get<AppDatabase>().taskDao;
   }, dependsOn: [AppDatabase]);
   getIt.registerSingletonWithDependencies<TaskRepository>(() => TaskRepository(), dependsOn: [TaskDao]);

  // view model for a task
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FilteredTaskList('Flutter Demo Home Page'),
    );
  }

}
