import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:todo_list/basic_widgets/task_list_checkbox.dart';
import 'package:todo_list/date_utils.dart';
import 'package:todo_list/task/task_model.dart';
import 'package:todo_list/task/taskList/task_list_vm.dart';

import 'edit_task_modal.dart';
import 'edit_task_vm.dart';

class EditTaskModalView extends State<EditTaskModal> {
  late EditTaskVM _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = EditTaskVM(widget.taskListVM, widget.task);
    _viewmodel.init();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [buildFormItems(context), buildItemModButtons(context)]));
  }

  Widget buildFormItems(BuildContext context) {
    DateTime in2Days = TaskListDateUtils.daysFromToday(2);

    return Column(
      children: [
        Row(
          children: [
            Card(
              child: ElevatedButton(
                onPressed: () {
                  _viewmodel.updateDeadline(TaskListDateUtils.today());
                },
                child: const Text("Today"),
              ),
            ),
            Card(
              child: ElevatedButton(
                onPressed: () {
                  _viewmodel.updateDeadline(TaskListDateUtils.tomorrow());
                },
                child: const Text("Tomorrow"),
              ),
            ),
            Card(
              child: ElevatedButton(
                onPressed: () {
                  _viewmodel.updateDeadline(TaskListDateUtils.tomorrow());
                },
                child: Text(TaskListDateUtils.getWeekday(in2Days)),
              ),
            ),
          ],
        ),
        buildFormItem(context,
            leading: TaskListCheckBox(_viewmodel.isCompleted,
                (val) => _viewmodel.onCheckToggle(context, val)),
            child: Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Task Title",
                ),
                autofocus: (_viewmodel.title == ""),
                controller: StyleableTextFieldController(
                  styles: TextPartStyleDefinitions(
                      definitionList: <TextPartStyleDefinition>[
                        TextPartStyleDefinition(
                            pattern: _viewmodel.dateRegex,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary))
                      ]),
                ),
              ),
            )),
        buildFormItem(context,
            leading:
                Transform.scale(scale: 1.3, child: const Icon(Icons.edit_note)),
            child: Expanded(
                child: TextField(
              decoration: const InputDecoration(
                hintText: "Description",
              ),
              controller: _viewmodel.descriptionController,
              style: Theme.of(context).textTheme.bodyLarge,
            )))
      ],
    );
  }

  Widget buildItemModButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: () {
              _selectDate(context);
            },
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined),
                Text(TaskListDateUtils.formatDate(_viewmodel.deadline)),
              ],
            )),
        IconButton(
            onPressed: () {
              _viewmodel.delete(context);
            },
            icon: const Icon(Icons.delete)),
        IconButton(
            onPressed: () {
              _viewmodel.submit(context);
            },
            icon: const Icon(Icons.send)),
      ],
    );
  }

  Widget buildFormItem(BuildContext context,
      {Widget? leading, required Widget child}) {
    return Card(
        child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      textBaseline: TextBaseline.ideographic,
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.only(right: 10),
          child: leading ?? const SizedBox.square(),
        ),
        child
      ],
    ));
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: TaskListDateUtils.today(),
      firstDate: TaskListDateUtils.today(),
      lastDate: DateTime(DateTime.timestamp().year + 5),
    );
    if (picked == null) {
      _viewmodel.updateDeadline(TaskListDateUtils.today());
    } else {
      _viewmodel.updateDeadline(picked);
    }
  }
}

Future<dynamic> openEditTaskModal(
    TaskModel task, TaskListVM taskListVM, BuildContext context) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return EditTaskModal(task, taskListVM);
      });
}

class StyleableTextFieldController extends TextEditingController {
  StyleableTextFieldController({
    required this.styles,
  }) : combinedPattern = styles.createCombinedPatternBasedOnStyleMap();

  final TextPartStyleDefinitions styles;
  final Pattern combinedPattern;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];

    text.splitMapJoin(
      combinedPattern,
      onMatch: (Match match) {
        final String? textPart = match.group(0);

        if (textPart == null) return '';

        final TextPartStyleDefinition? styleDefinition =
            styles.getStyleOfTextPart(
          textPart,
          text,
        );

        if (styleDefinition == null) return '';

        _addTextSpan(
          textSpanChildren,
          textPart,
          style?.merge(styleDefinition.style),
        );

        return '';
      },
      onNonMatch: (String text) {
        _addTextSpan(textSpanChildren, text, style);

        return '';
      },
    );

    return TextSpan(style: style, children: textSpanChildren);
  }

  void _addTextSpan(
    List<InlineSpan> textSpanChildren,
    String? textToBeStyled,
    TextStyle? style,
  ) {
    textSpanChildren.add(
      TextSpan(
        text: textToBeStyled,
        style: style,
      ),
    );
  }
}

class TextPartStyleDefinition {
  TextPartStyleDefinition({
    required this.pattern,
    required this.style,
  });

  final String pattern;
  final TextStyle style;
}

class TextPartStyleDefinitions {
  TextPartStyleDefinitions({required this.definitionList});

  final List<TextPartStyleDefinition> definitionList;

  RegExp createCombinedPatternBasedOnStyleMap() {
    final String combinedPatternString = definitionList
        .map<String>(
          (TextPartStyleDefinition textPartStyleDefinition) =>
              textPartStyleDefinition.pattern,
        )
        .join('|');

    return RegExp(
      combinedPatternString,
      multiLine: true,
      caseSensitive: false,
    );
  }

  TextPartStyleDefinition? getStyleOfTextPart(
    String textPart,
    String text,
  ) {
    return List<TextPartStyleDefinition?>.from(definitionList).firstWhere(
      (TextPartStyleDefinition? styleDefinition) {
        if (styleDefinition == null) return false;

        bool hasMatch = false;

        RegExp(styleDefinition.pattern, caseSensitive: false)
            .allMatches(text)
            .forEach(
          (RegExpMatch currentMatch) {
            if (hasMatch) return;

            if (currentMatch.group(0) == textPart) {
              hasMatch = true;
            }
          },
        );

        return hasMatch;
      },
      orElse: () => null,
    );
  }
}
