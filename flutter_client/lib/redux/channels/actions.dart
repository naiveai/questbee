import 'dart:async';
import 'package:draw/draw.dart';
import 'package:dio/dio.dart';

import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:questbee/models/channels.dart';

import 'package:questbee/pages/questions_page.dart';

ThunkAction<AppState> loadChannels(Reddit reddit) {
  return (Store<AppState> store) async {
    final channelSubbredditNames =
      List<String>.from((await
        Dio().get("https://questbee-d85f9.web.app/channelSubredditsList.json")).data);

    final channelFutures = channelSubbredditNames.map((String name) async {
      final channelSubreddit = await reddit.subreddit(name).populate();

      return ChannelModel((b) => b
        ..subredditName = name
        ..humanName = channelSubreddit.title
        ..iconImage = channelSubreddit.iconImage
      );
    });

    final channels = await Future.wait(channelFutures);

    store.dispatch(ChannelsLoadedAction(channels));
  };
}

class ChannelsLoadedAction {
  ChannelsLoadedAction(this.channels);

  List<ChannelModel> channels;
}
