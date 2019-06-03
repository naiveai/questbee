import 'package:flutter/foundation.dart';

@immutable
class RedditState {
  RedditState({this.credentials});

  final String credentials;

  factory RedditState.initialState() {
    return RedditState();
  }

  static RedditState fromJson(dynamic json) {
    return RedditState(
      credentials: json['credentials'],
    );
  }

  dynamic toJson() {
    return {
      'credentials': credentials,
    };
  }
}
