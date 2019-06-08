import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

import 'package:questbee/redux/app_state.dart';
import 'package:questbee/redux/reddit_auth/actions.dart';

import 'package:questbee/utils/reddit_api_wrapper.dart';
import 'package:provider/provider.dart';

import 'package:questbee/pages/login_page.dart';
import 'package:questbee/pages/channels_page.dart';
import 'package:questbee/pages/oauth_pages.dart';
import 'package:questbee/pages/questions_page.dart';

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
            '/': (context) {
              String credentials = store.state.redditState.credentials;

              if (credentials != null) {
                return SplashScreen(credentials);
              } else {
                return LoginPage();
              }
            },
            LoginPage.route: (context) => LoginPage(),
            ChannelsPage.route: (context) => ChannelsPage(),
            RedditOAuthLauncherPage.route: (context) =>
                RedditOAuthLauncherPage(),
            RedditOAuthRedirectPage.route: (context) =>
                RedditOAuthRedirectPage(),
            QuestionsPage.route: (context) => QuestionsPage(),
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  SplashScreen(this.credentials);

  final String credentials;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreBuilder<AppState>(
        onInitialBuild: (store) {
          var wrapper = Provider.of<RedditAPIWrapper>(context);

          wrapper
            .initializeWithCredentials(credentials)
            .then((_) => store.dispatch(signedInAction(wrapper.client)))
            .catchError((_) =>
                store.dispatch(NavigateToAction.replace(LoginPage.route)));
        },
        builder: (_, __) => Container(),
      ),
    );
  }
}
