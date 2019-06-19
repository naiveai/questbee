import 'package:flutter/foundation.dart';

import 'package:questbee/models/questions.dart';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

part 'state.g.dart';

abstract class QuestionsState implements Built<QuestionsState, QuestionsStateBuilder> {
  static Serializer<QuestionsState> get serializer => _$questionsStateSerializer;

  bool get isFetching;
  BuiltList<QuestionModel> get questions;
  BuiltMap<QuestionModel, BuiltList<String>> get answers;

  factory QuestionsState.initialState() {
    return QuestionsState((b) => b
      ..isFetching = false
      ..questions.replace(BuiltList<QuestionModel>())
      ..answers.replace(BuiltMap<QuestionModel, BuiltList<String>>())
    );
  }

  QuestionsState._();
  factory QuestionsState([void Function(QuestionsStateBuilder) updates]) = _$QuestionsState;
}
