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

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:built_collection/built_collection.dart';

class QuestionsPage extends StatefulWidget {
  static final String route = '/questions';

  QuestionsPage({Key key}) : super(key: key);

  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  RefreshController _refreshController;

  @override
  void initState() {
    super.initState();

    _refreshController = RefreshController();
  }

  void dispose() {
    _refreshController.dispose();

    super.dispose();
  }

  Widget _buildAppBar(BuildContext context, _QuestionsViewModel vm) {
    final reddit = Provider.of<RedditAPIWrapper>(context).client;

    return AppBar(
      title: Text(vm.channels.length == 0 || vm.channels.length > 1
          ? 'Feed'
          : vm.channels[0].humanName),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.assignment),
          tooltip: 'Subscribed channels',
          onPressed: () {
            Navigator.of(context).pushNamed(ChannelsPage.route)
              .then((_) => vm.loadQuestions(reddit));
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
        final question = vm.questions[index];

        return Dismissible(
          key: Key(question.questionId),
          onDismissed: (_) {
            vm.onDismissQuestion(question);

            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text("Question dismissed")));
          },
          child: Question(
            question: question,
            headers: <Widget>[
              Text(
                question.channel.humanName,
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.start,
              ),
              Divider(),
            ],
            footers: <Widget>[
              ButtonTheme.bar(
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: Text('SUBMIT'),
                      onPressed: () {
                        vm.onSubmit(reddit, question);
                      },
                    ),
                  ],
                ),
              ),
            ],
            onAnswersChanged: (List<String> answers) {
              vm.onAnswersChanged(question, answers);
            },
          ),
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
        if (!vm.isFetching && _refreshController.isRefresh) {
          _refreshController.refreshCompleted();
        }

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
          body: SmartRefresher(
            header: MaterialClassicHeader(),
            enablePullDown: true,
            controller: _refreshController,
            onRefresh: () {
              vm.loadQuestions(reddit, isRefresh: true);
            },
            child: _buildQuestionsList(context, vm),
          ),
        );
      },
    );
  }
}

class _QuestionsViewModel {
  _QuestionsViewModel({
    this.isFetching, this.channels, this.loadQuestions, this.questions,
    this.onAnswersChanged, this.onSubmit, this.onDismissQuestion,
    this.clearQuestions
  });

  final bool isFetching;
  final BuiltList<ChannelModel> channels;
  final BuiltList<QuestionModel> questions;

  final Function loadQuestions;
  final Function onAnswersChanged;
  final Function onSubmit;
  final Function onDismissQuestion;
  final Function clearQuestions;

  static _QuestionsViewModel fromStore(Store<AppState> store) {
    return _QuestionsViewModel(
      isFetching: store.state.questionsState.isFetching,
      channels: store.state.preferencesState.subscribedChannels,
      questions: store.state.questionsState.questions,
      loadQuestions: (reddit, {bool isRefresh = false}) {
        store.dispatch(
          loadQuestionsAction(reddit,
            store.state.preferencesState.subscribedChannels.toList(),
            isRefresh: isRefresh));
      },
      onAnswersChanged: (question, answers) {
        store.dispatch(AnswersChangedAction(question, answers));
      },
      onSubmit: (reddit, question) {
        store.dispatch(submitQuestionAction(reddit, question));
      },
      onDismissQuestion: (question) {
        store.dispatch(DismissQuestionAction(question));
      },
      clearQuestions: () {
        store.dispatch(ClearQuestionsAction());
      },
    );
  }

  bool operator ==(other) {
    return (
      other is _QuestionsViewModel &&
      other.isFetching == isFetching &&
      other.questions == questions &&
      other.channels == channels
    );
  }

  int get hashCode {
    return questions.hashCode ^ channels.hashCode ^ isFetching.hashCode;
  }
}

class Question extends StatefulWidget {
  Question(
      {Key key,
      this.headers = const [],
      this.footers = const [],
      @required this.question,
      @required this.onAnswersChanged})
      : super(key: key);

  final List<Widget> headers;
  final List<Widget> footers;
  final QuestionModel question;
  final Function(List<String>) onAnswersChanged;

  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  List<String> currentAnswers = [""];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ...widget.headers,
            for (final questionBlock in widget.question.questionBlocks)
              QuestionBlockView(questionBlock: questionBlock),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: (
                widget.question.numberOfCorrectAnswers == 1 ?
                  RadioButtonGroup(
                    labels: widget.question.answers.toList(),
                    itemBuilder: (Radio rb, Text txt, int i) {
                      return RadioListTile(
                        title: txt,
                        value: rb.value,
                        groupValue: rb.groupValue,
                        onChanged: rb.onChanged,
                      );
                    },
                    onSelected: (String selected) {
                      setState(() {
                        currentAnswers = [selected];
                      });

                      widget.onAnswersChanged(currentAnswers);
                    }
                  )
                  : CheckboxGroup(
                    labels: widget.question.answers.toList(),
                    disabled: (() {
                      if(currentAnswers.length ==
                          widget.question.numberOfCorrectAnswers) {
                        return List<String>.from(widget.question.answers
                            .where((answer) =>
                                !currentAnswers.contains(answer)));
                      }
                    })(),
                    itemBuilder: (Checkbox cb, Text txt, int i) {
                      return CheckboxListTile(
                        title: txt,
                        value: cb.value,
                        onChanged: cb.onChanged,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    },
                    onSelected: (List<String> selected) {
                      setState(() {
                        currentAnswers = selected;
                      });

                      widget.onAnswersChanged(currentAnswers);
                    }
                  )
              ),
            ),
            ...widget.footers,
          ],
        ),
      ),
    );
  }
}

class QuestionBlockView extends StatelessWidget {
  QuestionBlockView({Key key, @required this.questionBlock}) : super(key: key);

  final QuestionBlockModel questionBlock;

  @override
  Widget build(BuildContext context) {
    if (questionBlock.type == "text/plain") {
      final theme = Theme.of(context);

      return MarkdownBody(
        data: questionBlock.value.replaceAll("\n", "\n\n"),
        styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
          p: theme.textTheme.subhead,
        ),
        onTapLink: (url) async {
          if (await canLaunch(url)) {
            await launch(url);
          }
        },
      );
    }
  }
}
