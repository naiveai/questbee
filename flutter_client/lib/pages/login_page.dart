import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:questbee/redux/app_state.dart';
import 'package:questbee/redux/reddit_auth/actions.dart';

import 'package:questbee/utils/reddit_api_wrapper.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  static final String route = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("QuestBee", style: Theme.of(context).textTheme.display2),
              StoreConnector<AppState, VoidCallback>(
                converter: (store) => () {
                  final reddit =
                    Provider.of<RedditAPIWrapper>(context).initializeWithoutCredentials();

                  store.dispatch(startUserSignInAction(reddit));
                },
                builder: (context, callback) {
                  return SizedBox(
                    width: 300.0,
                    child: RaisedButton.icon(
                      onPressed: callback,
                      icon: Icon(MdiIcons.reddit),
                      label: Text("SIGN IN WITH REDDIT"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
