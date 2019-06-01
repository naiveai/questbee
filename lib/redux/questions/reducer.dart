import 'package:questbee/redux/questions/actions.dart';
import 'package:questbee/redux/questions/state.dart';

QuestionsState questionsReducer(QuestionsState state, dynamic action) {
  if (action is QuestionsLoadedAction) {
    return QuestionsState(
      questions: state.questions + action.questions
    );
  }

  return state;
}
