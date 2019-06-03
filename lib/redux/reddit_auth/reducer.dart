import 'package:questbee/redux/reddit_auth/state.dart';
import 'package:questbee/redux/reddit_auth/actions.dart';

RedditState redditReducer(RedditState state, dynamic action) {
  if (action is StoreCredentialsAction) {
    return RedditState(
      credentials: action.credentials,
    );
  }

  return state;
}
