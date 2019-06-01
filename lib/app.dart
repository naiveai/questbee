import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:questbee/utils/reddit_api_wrapper.dart';
import 'package:provider/provider.dart';

import 'package:questbee/pages/login_page.dart';
import 'package:questbee/pages/channels_page.dart';
import 'package:questbee/pages/oauth_pages.dart';

class App extends StatelessWidget {
  App({Key key, this.store}) : super(key: key);

  final Store<AppState> store;

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: Provider<RedditAPIWrapper>(
        builder: (context) => RedditAPIWrapper(),
        child: MaterialApp(
          navigatorKey: NavigatorHolder.navigatorKey,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.yellow[700],
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
              buttonColor: Colors.black87,
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => LoginPage(),
            LoginPage.route: (context) => LoginPage(),
            ChannelsPage.route: (context) => ChannelsPage(),
            RedditOAuthLauncherPage.route: (context) =>
                RedditOAuthLauncherPage(),
            RedditOAuthRedirectPage.route: (context) =>
                RedditOAuthRedirectPage(),
          },
        ),
      ),
    );
  }
}
