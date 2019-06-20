import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

import 'package:questbee/models/channels.dart';

part 'questions.g.dart';

abstract class QuestionModel implements Built<QuestionModel, QuestionModelBuilder> {
  static Serializer<QuestionModel> get serializer => _$questionModelSerializer;

  @BuiltValueField(compare: false)
  String get submissionId;

  ChannelModel get channel;
  String get questionId;
  int get numberOfCorrectAnswers;
  BuiltList<String> get answers;
  BuiltList<QuestionBlockModel> get questionBlocks;

  @BuiltValueField(compare: false)
  BuiltList<String> get submittedAnswers;

  QuestionModel._();
  factory QuestionModel([void Function(QuestionModelBuilder) updates]) = _$QuestionModel;

  String toString() {
    return "QuestionModel($questionId, $submissionId, $answers)";
  }
}

abstract class QuestionBlockModel implements Built<QuestionBlockModel, QuestionBlockModelBuilder> {
  static Serializer<QuestionBlockModel> get serializer => _$questionBlockModelSerializer;

  String get type;
  String get value;

  QuestionBlockModel._();
  factory QuestionBlockModel([void Function(QuestionBlockModelBuilder) updates]) = _$QuestionBlockModel;
}
