class QuestionModel {
  QuestionModel({this.questionId, this.numberOfCorrectAnswers, this.answers,
      this.questionBlocks});

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
