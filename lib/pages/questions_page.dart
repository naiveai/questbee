import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_redux_navigation/flutter_redux_navigation.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:provider/provider.dart';
import 'package:questbee/utils/reddit_api_wrapper.dart';

import 'package:questbee/models/channels.dart';
import 'package:questbee/models/questions.dart';

import 'package:questbee/redux/questions/actions.dart';

import 'package:questbee/pages/channels_page.dart';

import 'package:grouped_buttons/grouped_buttons.dart';

import 'package:draw/draw.dart';

class QuestionsPage extends StatefulWidget {
  static final String route = '/questions';

  QuestionsPage({Key key}) : super(key: key);

  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  Widget _buildAppBar(BuildContext context, _QuestionsViewModel vm) {
    final reddit = Provider.of<RedditAPIWrapper>(context).client;

    return AppBar(
      title: Text(vm.channels.length == 0 || vm.channels.length > 1
          ? 'Feed'
          : vm.channels[0].humanName),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.assignment),
          onPressed: () async {
            await Navigator.of(context).pushNamed(ChannelsPage.route);

            vm.loadQuestions(reddit);
          }
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(MdiIcons.clipboardAlert, size: 100.0),
          Text('No channels', style: Theme.of(context).textTheme.headline),
          Text('Subscribe to some using the button in the bar.'),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context, _QuestionsViewModel vm) {
    final reddit = Provider.of<RedditAPIWrapper>(context).client;

    return ListView.separated(
      itemCount: vm.questions.length,
      itemBuilder: (BuildContext context, int index) {
        return Question(
          question: vm.questions[index],
          headers: <Widget>[
            Text(
              vm.channels
                .singleWhere((channel) =>
                    channel.subredditName ==
                    vm.questions[index].submission.subreddit
                        .displayName)
                .humanName,
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.start,
            ),
          ],
          onAnswersChanged: (List<String> answers) {
            vm.onAnswersChanged(index, answers);
          },
          onSubmit: () {
            vm.onSubmit(reddit, index);
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 15.0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reddit = Provider.of<RedditAPIWrapper>(context).client;

    return StoreConnector<AppState, _QuestionsViewModel>(
      converter: _QuestionsViewModel.fromStore,
      distinct: true,
      onInitialBuild: (_QuestionsViewModel vm) {
        vm.loadQuestions(reddit);
      },
      onDispose: (store) {
        store.dispatch(ClearQuestionsAction());
      },
      builder: (BuildContext context, _QuestionsViewModel vm) {
        if (vm.channels.length == 0) {
          return Scaffold(
            appBar: _buildAppBar(context, vm),
            body: _buildEmptyState(context)
          );
        }

        if (vm.questions.length == 0) {
          return Scaffold(
            appBar: _buildAppBar(context, vm),
            body: Center(
              child: CircularProgressIndicator()
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(context, vm),
          body: _buildQuestionsList(context, vm),
        );
      },
    );
  }
}

class _QuestionsViewModel {
  _QuestionsViewModel({this.channels, this.loadQuestions, this.questions,
    this.onAnswersChanged, this.onSubmit, this.clear});

  final List<ChannelModel> channels;
  final List<QuestionModel> questions;

  final Function loadQuestions;
  final Function onAnswersChanged;
  final Function onSubmit;
  final Function clear;

  static _QuestionsViewModel fromStore(Store<AppState> store) {
    return _QuestionsViewModel(
      channels: store.state.preferencesState.subscribedChannels,
      questions: store.state.questionsState.questions,
      loadQuestions: (Reddit reddit) {
        if (store.state.preferencesState.subscribedChannels.length != 0) {
          store.dispatch(loadQuestionsAction(reddit,
                  store.state.preferencesState.subscribedChannels));
        }
      },
      onAnswersChanged: (index, answers) {
        store.dispatch(AnswersChangedAction(index, answers));
      },
      onSubmit: (reddit, index) {
        store.dispatch(submitQuestionAction(reddit, index));
      },
      clear: () => store.dispatch(ClearQuestionsAction()),
    );
  }

  bool operator ==(other) {
    return (other is _QuestionsViewModel && other.questions == questions &&
        other.channels == channels);
  }

  int get hashCode {
    return questions.hashCode ^ channels.hashCode;
  }
}

class Question extends StatefulWidget {
  Question(
      {Key key,
      this.headers = const [],
      @required this.question,
      @required this.onAnswersChanged,
      @required this.onSubmit})
      : super(key: key);

  final List<Widget> headers;
  final QuestionModel question;
  final Function(List<String>) onAnswersChanged;
  final Function() onSubmit;

  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  List<String> currentAnswers = [""];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ...widget.headers,
            Divider(),
            for (final questionBlock in widget.question.questionBlocks)
              if (questionBlock.type == "text/plain")
                Text(questionBlock.value.replaceAll("\n", "\n\n"), style:
                    Theme.of(context).textTheme.subhead),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: (widget.question.numberOfCorrectAnswers == 1
                  ? RadioButtonGroup(
                      labels: widget.question.answers,
                      itemBuilder: (Radio rb, Text txt, int i) {
                        return ListTile(
                          leading: rb,
                          title: txt,
                        );
                      },
                      onSelected: (String selected) => widget.onAnswersChanged([selected]),
                    )
                  : CheckboxGroup(
                      labels: widget.question.answers,
                      itemBuilder: (Checkbox cb, Text txt, int i) {
                        return ListTile(leading: cb, title: txt);
                      },
                      onSelected: widget.onAnswersChanged,
                    )),
            ),
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: Text('SUBMIT'),
                    // onPressed: widget.onSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
