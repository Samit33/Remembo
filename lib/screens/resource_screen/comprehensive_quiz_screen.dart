import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ComprehensiveQuizScreen extends StatefulWidget {
  final String docId;
  final int totalQuestions;
  final Function(int) onQuizComplete;

  const ComprehensiveQuizScreen({
    Key? key,
    required this.docId,
    required this.totalQuestions,
    required this.onQuizComplete,
  }) : super(key: key);

  @override
  _ComprehensiveQuizScreenState createState() =>
      _ComprehensiveQuizScreenState();
}

class _ComprehensiveQuizScreenState extends State<ComprehensiveQuizScreen> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> quizQuestions = [];
  String? selectedAnswer;
  int score = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comprehensive Quiz')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user1')
            .doc(widget.docId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data available'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          quizQuestions = (data['quiz_cards']?['args']?['quiz_cards'] as List?)
                  ?.map((card) => card as Map<String, dynamic>)
                  .toList() ??
              [];

          if (quizQuestions.isEmpty) {
            return Center(child: Text('No quiz questions available'));
          }

          Map<String, dynamic> currentQuestion =
              quizQuestions[currentQuestionIndex];
          String question = currentQuestion['Q'] ?? 'No question available';
          Map<String, dynamic> choices =
              Map.from(currentQuestion['choices'] ?? {});
          String correctAnswer = currentQuestion['correct_answer'] ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${widget.totalQuestions}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 16),
                  MarkdownBody(
                    data: question,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                      p: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SizedBox(height: 24),
                  ...choices.entries.map((choice) => RadioListTile(
                        title: Text(choice.value),
                        value: choice.key,
                        groupValue: selectedAnswer,
                        onChanged: (String? value) {
                          setState(() {
                            selectedAnswer = value;
                          });
                        },
                      )),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: currentQuestionIndex > 0
                            ? () {
                                setState(() {
                                  currentQuestionIndex--;
                                  selectedAnswer = null;
                                });
                              }
                            : null,
                        child: Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: selectedAnswer != null
                            ? () {
                                if (selectedAnswer == correctAnswer) {
                                  score++;
                                }
                                if (currentQuestionIndex <
                                    quizQuestions.length - 1) {
                                  setState(() {
                                    currentQuestionIndex++;
                                    selectedAnswer = null;
                                  });
                                } else {
                                  _finishQuiz();
                                }
                              }
                            : null,
                        child: Text(
                            currentQuestionIndex < quizQuestions.length - 1
                                ? 'Next'
                                : 'Finish'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _finishQuiz() async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(
          FirebaseFirestore.instance.collection('user1').doc(widget.docId));

      if (!snapshot.exists) {
        throw Exception("Document does not exist!");
      }

      transaction.set(
          FirebaseFirestore.instance.collection('user1').doc(widget.docId),
          {'quizScore': score},
          SetOptions(merge: true));
    });

    widget.onQuizComplete(score);
    Navigator.pop(context);
  }
}
