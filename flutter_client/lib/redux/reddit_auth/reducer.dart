import 'package:questbee/redux/reddit_auth/state.dart';
import 'package:questbee/redux/reddit_auth/actions.dart';

RedditState redditReducer(RedditState state, dynamic action) {
  switch(action.runtimeType) {
    case StoreCredentialsAction:
      return state.rebuild((b) => b
        .credentials = action.credentials
      );
    case UsernameFetchedAction:
      return state.rebuild((b) => b
        .username = action.username
      );
    default:
      return state;
  }
}
