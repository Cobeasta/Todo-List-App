import 'package:flutter/material.dart';

class TaskListCheckBox extends StatelessWidget {
  final bool _checked;
  final Function(bool? val) onToggle;

  const TaskListCheckBox(this._checked, this.onToggle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
        scale: 1.3,
        child: Checkbox(
          visualDensity: VisualDensity.compact,
          value: _checked,
          onChanged: onToggle,
          shape: const CircleBorder(),
        ));
  }
}
