import 'package:questbee/redux/questions/actions.dart';
import 'package:questbee/redux/questions/state.dart';

import 'package:questbee/redux/preferences/actions.dart';

var _initial = QuestionsState.initialState();

QuestionsState questionsReducer(QuestionsState state, dynamic action) {
  if (action is QuestionsLoadedAction) {
    var newQuestions = action.questions.reversed.toList();

    return QuestionsState(
      questions: newQuestions,
      answers: List.filled(newQuestions.length, null, growable: true),
    );
  } else if (action is AnswersChangedAction) {
    var newAnswers = state.answers;

    newAnswers[action.index] = action.answers;

    return QuestionsState(
      questions: state.questions,
      answers: newAnswers,
    );
  } else if (action is ClearQuestionsAction || action is
      SubscribedToChannelAction || action is UnsubscribedFromChannelAction) {
    return _initial;
  }

  return state;
}
