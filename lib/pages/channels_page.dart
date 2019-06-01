import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:provider/provider.dart';
import 'package:questbee/utils/reddit_api_wrapper.dart';

import 'package:questbee/redux/channels/actions.dart';

import 'package:questbee/models/channels.dart';

class ChannelsPage extends StatelessWidget {
  static final String route = '/channels';

  @override
  Widget build(BuildContext context) {
    var reddit = Provider.of<RedditAPIWrapper>(context).client;

    return Scaffold(
      appBar: AppBar(
        title: Text('Channels')
      ),
      body: StoreConnector<AppState, _ChannelViewModel>(
        converter: _ChannelViewModel.fromStore,
        onInit: (store) {
          store.dispatch(loadChannels(reddit));
        },
        builder: (BuildContext context, _ChannelViewModel vm) {
          if (vm.channels == null) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
              children: List<Widget>.from(vm.channels.map((channel) {
                return Text('${channel.subredditName} : ${channel.humanName}');
              })),
          );
        }
      ),
    );
  }
}

class _ChannelViewModel {
  _ChannelViewModel({this.channels});

  final List<ChannelModel> channels;

  static _ChannelViewModel fromStore(Store<AppState> store) {
    return _ChannelViewModel(
      channels: store.state.channelsState.channels,
    );
  }
}
