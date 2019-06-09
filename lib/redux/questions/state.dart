import 'package:flutter/foundation.dart';

import 'package:questbee/models/questions.dart';

@immutable
class QuestionsState {
  QuestionsState({this.isFetching, this.questions, this.answers});

  final bool isFetching;
  final List<QuestionModel> questions;
  final List<List<String>> answers;

  factory QuestionsState.initialState() {
    return QuestionsState(
      isFetching: false,
      questions: [],
      answers: [],
    );
  }
}
