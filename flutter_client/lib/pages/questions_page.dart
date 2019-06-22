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
import 'package:shimmer/shimmer.dart';

import 'package:built_collection/built_collection.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math';

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
              .then((_) => vm.loadQuestions(reddit, isRefresh: true));
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

  Widget _buildLoadingState(BuildContext context) {
    final fakeQuestion = QuestionModel((b) => b
      ..submissionId = ""
      ..numberOfCorrectAnswers = 2
      ..channel.replace(ChannelModel(
        (b) => b..subredditName = ""..humanName = "Fake Subreddit Name"))
      ..questionId = ""
      ..answers.replace(BuiltList<String>(["AAAAAAAAAA", "BBBBBBBB", "CCCCCCC", "DDDDDDDD"]))
      ..questionBlocks.replace(BuiltList<QuestionBlockModel>([
        QuestionBlockModel((b) => b
          ..type = "text/plain"
          ..value = """
          """
        )
      ]))
    );

    final random = Random();

    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 8.0,
                  color: Colors.white,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2.0),
                ),
                Container(
                  width: double.infinity,
                  height: 8.0,
                  color: Colors.white,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2.0),
                ),
                Container(
                  width: random.nextBool() ? double.infinity : random.nextDouble() * 240.0,
                  height: 8.0,
                  color: Colors.white,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10.0),
                ),
                Container(
                  width: random.nextBool() ? double.infinity : random.nextDouble() * 240.0,
                  height: 8.0,
                  color: Colors.white,
                ),
                Column(
                  children: <Widget>[
                    Radio(
                      value: 1,
                      groupValue: null,
                      onChanged: null,
                    ),
                    Radio(
                      value: 2,
                      groupValue: null,
                      onChanged: null,
                    ),
                    Radio(
                      value: 3,
                      groupValue: null,
                      onChanged: null,
                    ),
                    Radio(
                      value: 4,
                      groupValue: null,
                      onChanged: null,
                    ),
                  ],
                ),
              ],
            ),
          )
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 15.0);
      },
    );
  }

  Widget _buildQuestionsList(BuildContext context, _QuestionsViewModel vm) {
    final firestore = Provider.of<Firestore>(context);

    return ListView.separated(
      itemCount: vm.questions.length,
      itemBuilder: (BuildContext context, int index) {
        final question = vm.questions[index];

        final submittedAnswers =
            vm.submittedAnswers[question.questionId]?.asList();
        final submittedAnswersExists =
            submittedAnswers != null && submittedAnswers.length > 0;

        final noAnswersAfterSubmit =
          (submittedAnswersExists && vm.answers[question]?.length == 0);

        final canSubmitQuestion =
          (vm.answers[question]?.length == question.numberOfCorrectAnswers) ||
          noAnswersAfterSubmit;

        return Question(
          question: question,
          initialAnswers: submittedAnswers ?? [],
          headers: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  question.channel.humanName,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.start,
                ),
                if(submittedAnswersExists) ...[
                  Spacer(),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  Text('Answered'),
                ]
              ],
            ),
            Divider(),
          ],
          footers: <Widget>[
            ButtonTheme.bar(
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: Text(
                      !noAnswersAfterSubmit ?
                      (submittedAnswersExists ? 'CHANGE ANSWER' : 'ANSWER')
                      : 'REMOVE ANSWER'
                    ),
                    onPressed: canSubmitQuestion ? () {
                      vm.onSubmit(firestore, question);
                    } : null,
                  ),
                ],
              ),
            ),
          ],
          onAnswersChanged: (List<String> answers) {
            vm.onAnswersChanged(question, answers);
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
        store.dispatch(StopLoadingSubmittedAnswersAction());
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
            body: _buildLoadingState(context),
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
    this.isFetching, this.channels, this.questions,
    this.answers, this.submittedAnswers,
    this.loadQuestions, this.onAnswersChanged,
    this.onSubmit, this.clearQuestions
  });

  final bool isFetching;
  final BuiltList<ChannelModel> channels;
  final BuiltList<QuestionModel> questions;
  final BuiltMap<QuestionModel, BuiltList<String>> answers;
  final BuiltMap<String, BuiltList<String>> submittedAnswers;

  final Function loadQuestions;
  final Function onAnswersChanged;
  final Function onSubmit;
  final Function clearQuestions;

  static _QuestionsViewModel fromStore(Store<AppState> store) {
    return _QuestionsViewModel(
      isFetching: store.state.questionsState.isFetching,
      channels: store.state.preferencesState.subscribedChannels,
      questions: store.state.questionsState.questions,
      answers: store.state.questionsState.answers,
      submittedAnswers: store.state.questionsState.submittedAnswers,
      loadQuestions: (reddit, {bool isRefresh = false}) {
        store.dispatch(
          loadQuestionsAction(reddit,
            store.state.preferencesState.subscribedChannels.toList(),
            isRefresh: isRefresh));
      },
      onAnswersChanged: (question, answers) {
        store.dispatch(AnswersChangedAction(question, answers));
      },
      onSubmit: (firestore, question) {
        store.dispatch(submitQuestionAction(firestore, question));
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
      other.channels == channels &&
      other.answers == answers &&
      other.submittedAnswers == submittedAnswers
    );
  }

  int get hashCode {
    return questions.hashCode ^ channels.hashCode ^ isFetching.hashCode ^
        answers.hashCode ^ submittedAnswers.hashCode;
  }
}

class Question extends StatefulWidget {
  Question(
      {Key key,
      this.headers = const [],
      this.footers = const [],
      this.initialAnswers,
      @required this.question,
      @required this.onAnswersChanged})
      : super(key: key);

  final List<Widget> headers;
  final List<Widget> footers;
  final QuestionModel question;
  final List<String> initialAnswers;
  final Function(List<String>) onAnswersChanged;

  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  List<String> currentAnswers;

  @override
  void initState() {
    super.initState();
    currentAnswers = widget.initialAnswers;
  }

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
            SizedBox(height: 5.0),
            if (widget.question.numberOfCorrectAnswers != 1)
              Text("Select ${widget.question.numberOfCorrectAnswers} answers:"),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: (
                widget.question.numberOfCorrectAnswers == 1 ?
                  RadioButtonGroup(
                    labels: widget.question.answers.toList(),
                    picked: (() {
                      try {
                        return currentAnswers?.elementAt(0);
                      } on RangeError {
                        return "";
                      }
                    })(),
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
                        if (currentAnswers.contains(selected)) {
                          currentAnswers = [];
                        } else {
                          currentAnswers = [selected];
                        }
                      });

                      widget.onAnswersChanged(currentAnswers);
                    }
                  )
                  : CheckboxGroup(
                    labels: widget.question.answers.toList(),
                    checked: currentAnswers,
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
