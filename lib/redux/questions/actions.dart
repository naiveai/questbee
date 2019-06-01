import 'package:draw/draw.dart';
import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:questbee/models/questions.dart';

import 'package:flutter/foundation.dart';

ThunkAction<AppState> loadQuestionsAction(Reddit reddit, String subredditName) {
  return (Store<AppState> store) async {
    var latestQuestionsRaw =
        await reddit.subreddit(subredditName).stream.submissions(limit: 5, pauseAfter: 1)
          .takeWhile((submission) => submission != null)
          .toList();

    store.dispatch(QuestionsLoadedAction(
      latestQuestionsRaw.map((submission) {
        var questionInfo = json.decode(submission.selftext);

        return QuestionModel(
          questionId: questionInfo['questionId'],
          numberOfCorrectAnswers: int.parse(questionInfo['numberOfCorrectAnswers']),
          answers: List<String>.from(questionInfo['answers']),
          questionBlocks: List<QuestionBlockModel>.from(questionInfo['question'].map((block) =>
              QuestionBlockModel(block['type'], block['value']))),
        );
      }).toList()
    ));
  };
}

class QuestionsLoadedAction {
  List<QuestionModel> questions;

  QuestionsLoadedAction(this.questions);
}

class ClearQuestionsAction {}

class AnswersChangedAction {
  int index;
  List<String> answers;

  AnswersChangedAction(this.index, this.answers);
}
