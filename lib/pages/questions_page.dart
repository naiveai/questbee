import 'package:flutter/material.dart';

import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:questbee/redux/app_state.dart';

import 'package:provider/provider.dart';
import 'package:questbee/utils/reddit_api_wrapper.dart';

import 'package:questbee/models/channels.dart';
import 'package:questbee/models/questions.dart';

import 'package:questbee/redux/questions/actions.dart';

import 'package:grouped_buttons/grouped_buttons.dart';

class QuestionsPage extends StatelessWidget {
  static final String route = '/questions';

  @override
  Widget build(BuildContext context) {
    final reddit = Provider.of<RedditAPIWrapper>(context).client;
    final ChannelModel channel =
        (ModalRoute.of(context).settings.arguments as Map)['channel'];

    return Scaffold(
      appBar: AppBar(title: Text(channel.humanName)),
      body: StoreConnector<AppState, _QuestionsViewModel>(
          converter: _QuestionsViewModel.fromStore,
          onInit: (store) {
            store.dispatch(loadQuestionsAction(reddit, channel.subredditName));
          },
          onDispose: (store) {
            store.dispatch(ClearQuestionsAction());
          },
          builder: (BuildContext context, _QuestionsViewModel vm) {
            if (vm.questions.length == 0) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.separated(
              itemCount: vm.questions.length,
              itemBuilder: (BuildContext context, int index) {
                return Question(
                  question: vm.questions[index],
                  onAnswersChanged: (List<String> answers) {
                    vm.onAnswersChanged(index, answers);
                  },
                  onSubmit: () {
                    vm.onSubmit(reddit, index);
                  }
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 15.0);
              },
            );
          }),
    );
  }
}

class _QuestionsViewModel {
  _QuestionsViewModel({this.questions, this.onAnswersChanged, this.onSubmit});

  final List<QuestionModel> questions;
  final Function(int, List<String>) onAnswersChanged;
  final Function onSubmit;

  static _QuestionsViewModel fromStore(Store<AppState> store) {
    return _QuestionsViewModel(
      questions: store.state.questionsState.questions,
      onAnswersChanged: (index, answers) {
        store.dispatch(AnswersChangedAction(index, answers));
      },
      onSubmit: (reddit, index) {
        store.dispatch(submitQuestionAction(reddit, index));
      }
    );
  }
}

class Question extends StatefulWidget {
  Question({Key key, @required this.question, @required this.onAnswersChanged, @required this.onSubmit}) : super(key: key);

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
          mainAxisSize: MainAxisSize.min,
          children: (List<Widget>.from(
              widget.question.questionBlocks.map((questionBlock) {
                if (questionBlock.type == "text/plain") {
                  return Text(questionBlock.value,
                      style: Theme.of(context).textTheme.title);
                }
              }).toList()) + <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: (widget.question.numberOfCorrectAnswers == 1 ?
                      RadioButtonGroup(
                        labels: widget.question.answers,
                        itemBuilder: (Radio rb, Text txt, int i) {
                          return ListTile(
                            leading: rb,
                            title: txt,
                          );
                        },
                        onSelected: (String selected) {
                          widget.onAnswersChanged([selected]);
                        }
                      ) :
                      CheckboxGroup(
                        labels: widget.question.answers,
                        itemBuilder: (Checkbox cb, Text txt, int i) {
                          return ListTile(
                            leading: cb,
                            title: txt
                          );
                        },
                        onSelected: (List<String> checked) {
                          widget.onAnswersChanged(checked);
                        }
                      )
                  ),
                ),
                ButtonTheme.bar(
                  child: ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Text('SUBMIT'),
                        onPressed: widget.onSubmit,
                      ),
                    ],
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }
}
