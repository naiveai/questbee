import 'package:questbee/redux/questions/actions.dart';
import 'package:questbee/redux/questions/state.dart';
import 'package:questbee/models/questions.dart';

import 'package:questbee/redux/preferences/actions.dart';

import 'package:built_collection/built_collection.dart';

var _initial = QuestionsState.initialState();

QuestionsState questionsReducer(QuestionsState state, dynamic action) {
  switch(action.runtimeType) {
    case QuestionsLoadedAction:
      return state.rebuild((b) => b
        ..isFetching = false
        ..questions.addAll(action.questions)
      );
    case StartLoadingQuestionsAction:
      return state.rebuild((b) => b
        .isFetching = true
      );
    case AnswersChangedAction:
      return state.rebuild((b) => b
        .answers[action.question] = BuiltList<String>(action.answers)
      );
    case ClearQuestionsAction:
    case SubscribedToChannelAction:
    case UnsubscribedFromChannelAction:
      return _initial;
    case SubmittedQuestionAction:
      return state;
    default:
      return state;
  }
}
