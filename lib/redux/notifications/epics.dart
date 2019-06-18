import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:questbee/redux/app_state.dart';
import 'package:questbee/redux/preferences/actions.dart';

Epic<AppState> channelSubscriptionNotificationsEpic(FirebaseMessaging firebaseMessaging) {
  return (Stream actions, EpicStore<AppState> store) async* {
    var bufferedSubscriptionActions = Observable(actions)
      .ofType(TypeToken<ChangeChannelSubscriptionAction>())
      .buffer(Observable.periodic(Duration(milliseconds: 750)))
      .where((subscriptionActions) => subscriptionActions.length != 0);

    await for (List subscriptionActions in bufferedSubscriptionActions) {
      Map<String, int> finalActions = {};

      for (final action in subscriptionActions) {
        final topicName = action.channel.subredditName;

        finalActions.putIfAbsent(topicName, () => 0);
        finalActions[topicName] += (action is SubscribedToChannelAction) ? 1 : -1;
      }

      for (final entry in finalActions.entries) {
        final topicName = entry.key;
        final finalAction = entry.value;

        if(finalAction == 1) {
          firebaseMessaging.subscribeToTopic(topicName);
        } else if(finalAction == -1) {
          firebaseMessaging.unsubscribeFromTopic(topicName);
        }
      }
    }
  };
}
