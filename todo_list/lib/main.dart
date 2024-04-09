import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo_list/di.dart';
import 'package:todo_list/task/taskList/TaskList.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await configureDependencies();
    runApp(const MyApp());
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


