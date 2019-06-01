import 'package:flutter/foundation.dart';

import 'package:questbee/models/questions.dart';

@immutable
class QuestionsState {
  QuestionsState({this.questions});

  final List<QuestionModel> questions;

  factory QuestionsState.initialState() {
    return QuestionsState(questions: []);
  }
}
