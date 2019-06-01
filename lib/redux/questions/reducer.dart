import 'package:questbee/redux/questions/actions.dart';
import 'package:questbee/redux/questions/state.dart';

QuestionsState questionsReducer(QuestionsState state, dynamic action) {
  if (action is QuestionsLoadedAction) {
    var newQuestions = state.questions + action.questions;

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
  } else if (action is ClearQuestionsAction) {
    return QuestionsState.initialState();
  }

  return state;
}
