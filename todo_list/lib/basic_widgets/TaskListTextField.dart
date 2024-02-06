import 'package:flutter/material.dart';

class TaskListTextField extends StatelessWidget {
  final String text;
  final String hint;
  final TextEditingController controller;
  final TextStyle? theme;

  const TaskListTextField(this.hint, this.text, this.controller, {super.key, this.theme});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: TextField(
          decoration: InputDecoration(
            hintText: hint,
          ),
          controller: controller,
          style: theme,
        ));
  }
}
