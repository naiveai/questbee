import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

import 'package:questbee/redux/app_state.dart';
import 'package:questbee/redux/questions/actions.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Epic<AppState> submittedAnswersEpic(Firestore firestore, FirebaseAuth auth) {
  getSubmittedAnswers() async* {
    final currentUserName = (await auth.currentUser())?.uid;

    if (currentUserName != null) {
      final documentsStream =
          firestore.document("users/$currentUserName").snapshots();

      await for (DocumentSnapshot doc in documentsStream) {
        yield (Map<String, List<dynamic>>.from(doc["submittedAnswers"]))
          .map((key, value) => MapEntry(key, List<String>.from(value)));
      }
    }
  }

  return (Stream actions, EpicStore<AppState> store) {
    final actionsObs = Observable(actions);

    return actionsObs
      .ofType(TypeToken<StartLoadingSubmittedAnswersAction>())
      .switchMap((action) {
        return Observable(getSubmittedAnswers())
          .map(
            (submittedAnswers) => SubmittedAnswersLoadedAction(submittedAnswers))
          .takeUntil(
            actionsObs.ofType(TypeToken<StopLoadingSubmittedAnswersAction>()));
      });
  };
}
