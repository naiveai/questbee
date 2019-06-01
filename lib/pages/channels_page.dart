import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    final reddit = Provider.of<RedditAPIWrapper>(context).client;

    return Scaffold(
      appBar: AppBar(title: Text('Channels')),
      body: StoreConnector<AppState, _ChannelViewModel>(
        converter: _ChannelViewModel.fromStore,
        onInit: (store) {
          store.dispatch(loadChannels(reddit));
        },
        builder: (BuildContext context, _ChannelViewModel vm) {
          if (vm.channels.length == 0) {
            return Center(child: CircularProgressIndicator());
          }

          return ChannelList(
            channels: vm.channels,
            onTap: vm.onChannelTap,
          );
        },
      ),
    );
  }
}

class _ChannelViewModel {
  _ChannelViewModel({this.channels, this.onChannelTap});

  final List<ChannelModel> channels;
  final Function(ChannelModel) onChannelTap;

  static _ChannelViewModel fromStore(Store<AppState> store) {
    return _ChannelViewModel(
      channels: store.state.channelsState.channels,
      onChannelTap: (channel) => store.dispatch(openChannelQuestions(channel)),
    );
  }
}

class ChannelList extends StatelessWidget {
  ChannelList({Key key, this.channels, this.onTap}) : super(key: key);

  final List<ChannelModel> channels;
  final Function(ChannelModel) onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: channels.length,
      itemBuilder: (BuildContext context, int index) {
        var currentChannel = channels[index];

        return Card(
          child: ListTile(
            leading: CachedNetworkImage(
              placeholder: (_, __) => CircularProgressIndicator(),
              errorWidget: (_, __, error) => Icon(MdiIcons.imageBroken),
              imageUrl: currentChannel.iconImage.toString(),
            ),
            title: Text(currentChannel.humanName),
            onTap: () => onTap(currentChannel),
          ),
        );
      },
    );
  }
}
