import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class QuizCard extends StatefulWidget {
  final String docId;
  final String sectionTitle;
  final Function? onQuizComplete;

  const QuizCard({
    Key? key,
    required this.docId,
    required this.sectionTitle,
    this.onQuizComplete,
  }) : super(key: key);

  @override
  _QuizCardState createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  int currentCardIndex = 0;
  String? selectedAnswer;
  bool answerSubmitted = false;
  List<Map<String, dynamic>> quizCards = [];
  int correctAnswers = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.sectionTitle}'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
          quizCards = (data['quiz_cards']?['args']?['quiz_cards'] as List?)
                  ?.map((card) => card as Map<String, dynamic>)
                  .toList() ??
              [];

          if (widget.sectionTitle != 'All Sections') {
            quizCards = quizCards
                .where((card) => card['section_title'] == widget.sectionTitle)
                .toList();
          }

          if (quizCards.isEmpty) {
            return Center(
                child: Text('No quiz cards available for this section'));
          }

          Map<String, dynamic> currentCard = quizCards[currentCardIndex];
          String question = currentCard['Q'] ?? 'No question available';
          Map<String, dynamic> choices = Map.from(currentCard['choices'] ?? {});
          String correctAnswer = currentCard['correct_answer'] ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${currentCardIndex + 1} of ${quizCards.length}',
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
                        onChanged: answerSubmitted
                            ? null
                            : (String? value) {
                                setState(() {
                                  selectedAnswer = value;
                                });
                              },
                        activeColor: answerSubmitted
                            ? (choice.key == correctAnswer
                                ? Colors.green
                                : Colors.red)
                            : Theme.of(context).primaryColor,
                      )),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: currentCardIndex > 0
                            ? () {
                                setState(() {
                                  currentCardIndex--;
                                  selectedAnswer = null;
                                  answerSubmitted = false;
                                });
                              }
                            : null,
                        child: Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: selectedAnswer != null && !answerSubmitted
                            ? () {
                                setState(() {
                                  answerSubmitted = true;
                                  if (selectedAnswer == correctAnswer) {
                                    correctAnswers++;
                                  }
                                });
                              }
                            : null,
                        child: Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: answerSubmitted
                            ? () {
                                if (currentCardIndex < quizCards.length - 1) {
                                  setState(() {
                                    currentCardIndex++;
                                    selectedAnswer = null;
                                    answerSubmitted = false;
                                  });
                                } else {
                                  // Quiz completed
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Quiz Completed'),
                                        content: Text(
                                            'You got $correctAnswers out of ${quizCards.length} questions correct.'),
                                        actions: [
                                          TextButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                              if (widget.onQuizComplete !=
                                                  null) {
                                                widget.onQuizComplete!();
                                              }
                                              // Update user progress in Firebase
                                              FirebaseFirestore.instance
                                                  .collection('user1')
                                                  .doc(widget.docId)
                                                  .update({
                                                'currentSectionIndex':
                                                    FieldValue.increment(1),
                                              });
                                              // Navigate to Resource Screen
                                              Navigator.pushReplacementNamed(
                                                  context, '/resource_screen',
                                                  arguments: widget.docId);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            : null,
                        child: Text(currentCardIndex < quizCards.length - 1
                            ? 'Next'
                            : 'Next Section'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  if (answerSubmitted) ...[
                    SizedBox(height: 24),
                    Text(
                      selectedAnswer == correctAnswer
                          ? 'Correct!'
                          : 'Incorrect. The correct answer is: ${choices[correctAnswer]}',
                      style: TextStyle(
                        color: selectedAnswer == correctAnswer
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
