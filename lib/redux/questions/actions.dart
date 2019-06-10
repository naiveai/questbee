import 'package:draw/draw.dart';
import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:questbee/models/channels.dart';
import 'package:questbee/models/questions.dart';

ThunkAction<AppState> loadQuestionsAction(
    Reddit reddit, List<ChannelModel> channels) {
  return (Store<AppState> store) async {
    if (channels.length == 0) {
      store.dispatch(ClearQuestionsAction());
      return;
    }

    var subredditNames = channels.map((c) => c.subredditName).toList();

    store.dispatch(StartLoadingQuestionsAction());

    var latestQuestionsRaw = await reddit
        .subreddit(subredditNames.join('+')).stream
        .submissions(pauseAfter: 0)
        .takeWhile((submission) => submission != null)
        .toList();

    store.dispatch(QuestionsLoadedAction(latestQuestionsRaw.map((submission) {
      var questionInfo = json.decode(submission.selftext);

      return QuestionModel(
        submission: submission,
        questionId: questionInfo['questionId'],
        numberOfCorrectAnswers:
            int.parse(questionInfo['numberOfCorrectAnswers']),
        answers: List<String>.from(questionInfo['answers']),
        questionBlocks: List<QuestionBlockModel>.from(questionInfo['question']
            .map((block) => QuestionBlockModel(block['type'], block['value']))),
      );
    }).toList()));
  };
}

class StartLoadingQuestionsAction {}

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

ThunkAction<AppState> submitQuestionAction(Reddit reddit, int questionIndex) {
  return (Store<AppState> store) async {
    var submission =
        store.state.questionsState.questions[questionIndex].submission;
    var answers = store.state.questionsState.answers[questionIndex];

    await submission.reply(json.encode({'answers': answers}));
  };
}
