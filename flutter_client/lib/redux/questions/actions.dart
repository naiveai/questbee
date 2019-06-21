import 'package:draw/draw.dart';
import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:questbee/models/channels.dart';
import 'package:questbee/models/questions.dart';

import 'package:built_collection/built_collection.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


// TODO: Remove this using FirebaseAuth.onAuthStateChanged
import 'package:firebase_auth/firebase_auth.dart';

ThunkAction<AppState> loadQuestionsAction(
    Reddit reddit, List<ChannelModel> channels,
    {bool isRefresh = false}) {
  return (Store<AppState> store) async {
    if (channels.length == 0) {
      store.dispatch(ClearQuestionsAction());
      return;
    }

    final subredditNames = channels.map((c) => c.subredditName);

    store.dispatch(StartLoadingQuestionsAction());
    store.dispatch(StartLoadingSubmittedAnswersAction());

    final questionsResponse =
      await reddit.get("r/${subredditNames.join('+')}/new.json") as Map;

    if (isRefresh) {
      store.dispatch(ClearQuestionsAction());
    }

    final questions = questionsResponse['listing'];
    final continuationToken = questionsResponse['after'];

    for (final questionSubmission in questions) {
      final questionInfo = json.decode(questionSubmission.selftext);

      final question = QuestionModel((b) => b
        ..submissionId = questionSubmission.id
        ..questionId = questionInfo['questionId']
        ..channel.replace(channels.singleWhere((channel) =>
            channel.subredditName == questionSubmission.subreddit.displayName))
        ..numberOfCorrectAnswers = int.parse(questionInfo['numberOfCorrectAnswers'])
        ..answers.replace(BuiltList<String>(questionInfo['answers']))
        ..questionBlocks.replace(
            BuiltList<QuestionBlockModel>(
              questionInfo['question'].map(
                (block) => QuestionBlockModel((b) => b
                  ..type = block['type']
                  ..value = block['value']
                )
              )
            )
          )
        ..submittedAnswers.replace(BuiltList<String>())
      );

      store.dispatch(QuestionsLoadedAction([question]));
    }
  };
}

class StartLoadingQuestionsAction {}
class StartLoadingSubmittedAnswersAction {}

class QuestionsLoadedAction {
  List<QuestionModel> questions;

  QuestionsLoadedAction(this.questions);
}

class SubmittedAnswersLoadedAction {
  Map<String, List<String>> submittedAnswers;

  SubmittedAnswersLoadedAction(this.submittedAnswers);
}

class StopLoadingSubmittedAnswersAction {}

class ClearQuestionsAction {}

class AnswersChangedAction {
  QuestionModel question;
  List<String> answers;

  AnswersChangedAction(this.question, this.answers);
}

ThunkAction<AppState> submitQuestionAction(Firestore firestore, QuestionModel question) {
  return (Store<AppState> store) async {
    final answers = store.state.questionsState.answers[question].toList();
    final currentUserName = store.state.redditState.username;

    await firestore.document("users/$currentUserName").setData({
      "submittedAnswers": {
        question.questionId: answers,
      },
    }, merge: true);
  };
}

class SubmittedQuestionAction {
  QuestionModel question;

  SubmittedQuestionAction(this.question);
}
