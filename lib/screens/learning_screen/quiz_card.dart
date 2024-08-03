import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class QuizCard extends StatefulWidget {
  final String docId;
  final String sectionTitle;
  final int sectionIdentifier;

  const QuizCard(
      {Key? key,
      required this.docId,
      required this.sectionTitle,
      required this.sectionIdentifier})
      : super(key: key);

  @override
  _QuizCardState createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  int currentCardIndex = 0;
  String? selectedAnswer;
  bool answerSubmitted = false;
  List<Map<String, dynamic>> quizCards = [];
  int currentSectionIdentifier = 1;

  @override
  void initState() {
    super.initState();
    _fetchCurrentSectionIdentifier();
  }

  void _fetchCurrentSectionIdentifier() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user1')
        .doc(widget.docId)
        .get();
    if (snapshot.exists) {
      setState(() {
        currentSectionIdentifier = (snapshot.data()
                as Map<String, dynamic>)['currentSectionIdentifier'] ??
            1;
      });
    }
  }

  void _updateCurrentSectionIdentifier() {
    if (currentSectionIdentifier < widget.sectionIdentifier + 1) {
      FirebaseFirestore.instance.collection('user1').doc(widget.docId).update({
        'currentSectionIdentifier': widget.sectionIdentifier + 1,
      });
    }
  }

  void _navigateToResourceScreen() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/resource_screen',
          arguments: widget.docId);
    });
  }

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

          quizCards = quizCards
              .where((card) => card['section_title'] == widget.sectionTitle)
              .toList();

          if (quizCards.isEmpty) {
            _updateCurrentSectionIdentifier();
            _navigateToResourceScreen();
            return Center(
              child: Text(
                  'No quiz cards available for this section. Returning to the previous screen...'),
            );
          }

          Map<String, dynamic> currentCard;
          String question;
          Map<String, dynamic> choices;
          String correctAnswer;

          currentCard = quizCards[currentCardIndex];
          question = currentCard['Q'] ?? 'No question available';
          choices = Map.from(currentCard['choices'] ?? {});
          correctAnswer = currentCard['correct_answer'] ?? '';

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
                                    // correctAnswers++;
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
                                  if (currentSectionIdentifier <
                                      widget.sectionIdentifier + 1) {
                                    FirebaseFirestore.instance
                                        .collection('user1')
                                        .doc(widget.docId)
                                        .update({
                                      'currentSectionIdentifier':
                                          widget.sectionIdentifier + 1,
                                    });
                                  }

                                  Navigator.pushReplacementNamed(
                                      context, '/resource_screen',
                                      arguments: widget.docId);
                                }
                              }
                            : null,
                        child: Text(currentCardIndex < quizCards.length - 1
                            ? 'Next'
                            : 'Finish'),
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
