import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:uni_links/uni_links.dart';
import 'package:questbee/redux/deep_links/actions.dart';

Stream<dynamic> uriLinksEpic(Stream actions, EpicStore<AppState> store) {
  return Observable(getUriLinksStream())
    .map((Uri uri) => deepLinkRecievedAction(uri))
    .handleError((err) => DeepLinkErrorAction(err));
}
