import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/date_utils.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/task/task_model.dart';
import 'package:todo_list/task/task_repository.dart';
import 'package:todo_list/task/taskList/task_list_vm.dart';

class EditTaskVM extends ChangeNotifier {
  final TaskModel _taskModel;
  final TaskListVM _taskListVM;

  get task => _taskModel;

  EditTaskVM(this._taskListVM, this._taskModel);

  final TextEditingController _titleController = TitleTextFieldController();
  final TextEditingController _descriptionController = TextEditingController();

  TextEditingController get titleController => _titleController;

  TextEditingController get descriptionController => _descriptionController;

  bool get isCompleted => _taskModel.isComplete;

  String get title => _taskModel.title;

  String get description => _taskModel.description;

  DateTime get deadline => _taskModel.deadline;

  void init() {
    _descriptionController.text = _taskModel.description;
    _titleController.text = _taskModel.title;
    _titleController.addListener(titleControllerUpdate);
    _descriptionController.addListener(() {
      _taskModel.updateDescription(_descriptionController.text);
    });
  }

  void titleControllerUpdate() {
    bool notifyFlag = false;

    var textSplit = _titleController.text.split(r"\s");
    String newTitle = "";
    for (int i = 0; i < textSplit.length; i++) {
      if (textSplit[i].toLowerCase() == "today" ||
          textSplit[i].toLowerCase() == "tod") {
        _taskModel.updateDeadline(TaskListDateUtils.today());
        notifyFlag = true;
      } else {
        newTitle = "$newTitle ${textSplit[i].trim()}".trim();
      }
    }
    if (newTitle != title) {
      _taskModel.updateTitle(newTitle);
      notifyFlag = true;
    }

    if (notifyFlag) notifyListeners();
  }

  void updateDescription() {
    _taskModel.updateDescription(_descriptionController.text);
    notifyListeners();
  }

  void onCheckToggle(BuildContext context, bool? val) {
    _taskModel.setComplete(val);
    submit(context);
  }

  void updateDeadline(DateTime date) {
    _taskModel.updateDeadline(date);
    notifyListeners();
  }

  void delete(BuildContext context) {
    _taskListVM.removeTask(_taskModel);
    Navigator.pop(context);
  }

  void submit(BuildContext context) {
    if (kDebugMode) {
      print("EditTaskVM submit");
    }
    if (_taskModel.id == null) {
      _taskListVM.editTaskModalSubmit(_taskModel);
    } else {
      _taskListVM.updateTask(_taskModel);
    }
    notifyListeners();
    Navigator.pop(context, _taskModel);
  }
}

class TitleTextFieldController extends TextEditingController {
  TitleTextFieldController();

  final String dueTodayPattern = "tod(ay)?[\\s\$]";
  final String dueTomorrowPattern = "tom(orrow)?[\\s\$]";

  String get combinedDateRegexStr =>
      "(($dueTodayPattern)|($dueTomorrowPattern))(?!.*(($dueTodayPattern)|($dueTomorrowPattern)))";

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];

    Pattern combinedRegex = RegExp(
      combinedDateRegexStr,
      caseSensitive: false,
    );

    text.splitMapJoin(
      combinedRegex,
      onMatch: (Match match) {
        final String? textPart = match.group(0);

        if (textPart == null) return '';


        // if matches date regex
        if (combinedRegex.matchAsPrefix(textPart) != null) {
          _addTextSpan(
              textSpanChildren,
              textPart,
              TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  background: Paint()
                    ..strokeWidth = 2.0
                    ..color = Theme.of(context).colorScheme.primary
                    ..strokeCap = StrokeCap.round
                    ..style = PaintingStyle.fill
                    ..strokeJoin = StrokeJoin.round));
          return '';
        }
        return '';
      },
      onNonMatch: (String segment) {
        _addTextSpan(textSpanChildren, segment, style);
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
