import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

import 'package:questbee/redux/app_state.dart';
import 'package:questbee/redux/reddit_auth/actions.dart';

import 'package:firebase_auth/firebase_auth.dart';

Epic<AppState> authStateChangedEpic(FirebaseAuth auth) {
  return (Stream actions, EpicStore<AppState> store) {
    return auth.onAuthStateChanged
      .map((newUserData) => UsernameFetchedAction(newUserData?.uid));
  };
}
