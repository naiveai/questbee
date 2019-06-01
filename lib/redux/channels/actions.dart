import 'dart:async';
import 'package:draw/draw.dart';
import 'package:dio/dio.dart';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:questbee/models/channels.dart';

ThunkAction<AppState> loadChannels(Reddit reddit) {
  return (Store<AppState> store) async {
    var channelSubbredditNames =
        List<String>.from((await
                Dio().get("https://questbee-data.s3.amazonaws.com/channel_subreddits.json")).data);

    var channelFutures = channelSubbredditNames.map((String name) async {
      var humanName = (await reddit.subreddit(name).populate()).title;

      return ChannelModel(name, humanName);
    });

    var channels = await Future.wait(channelFutures);

    store.dispatch(ChannelsLoadedAction(channels));
  };
}

class ChannelsLoadedAction {
  ChannelsLoadedAction(this.channels);

  List<ChannelModel> channels;
}
