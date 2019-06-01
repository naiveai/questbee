import 'package:draw/draw.dart';

class QuestionModel {
  QuestionModel({this.submission, this.questionId, this.numberOfCorrectAnswers, this.answers,
      this.questionBlocks});

  final Submission submission;
  final String questionId;
  final int numberOfCorrectAnswers;
  final List<String> answers;
  final List<QuestionBlockModel> questionBlocks;
}

class QuestionBlockModel {
  QuestionBlockModel(this.type, this.value);

  final String type;
  final String value;
}
