import 'package:flutter/foundation.dart';

import 'package:questbee/models/questions.dart';

@immutable
class QuestionsState {
  QuestionsState({this.questions, this.answers});

  final List<QuestionModel> questions;
  final List<List<String>> answers;

  factory QuestionsState.initialState() {
    return QuestionsState(
      questions: [],
      answers: [],
    );
  }
}
