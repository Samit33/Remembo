import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class QuizCard extends StatefulWidget {
  final String docId;
  final String sectionTitle;
  final Function(int, int)? onQuizComplete;

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
  int currentSectionIndex = 0;

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

          return _buildQuizContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildQuizContent(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    currentSectionIndex = data['current_section_index'] ?? 0;
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
      return _handleEmptyQuizCards();
    }

    Map<String, dynamic> currentCard = quizCards[currentCardIndex];
    String question = currentCard['Q'] ?? 'No question available';
    Map<String, dynamic> choices = Map.from(currentCard['choices'] ?? {});
    String correctAnswer = currentCard['correct_answer'] ?? '';
    int sectionIdentifier = _getSectionIdentifier(currentCard);

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
            _buildQuestion(question),
            SizedBox(height: 24),
            ..._buildChoices(choices, correctAnswer),
            SizedBox(height: 24),
            _buildNavigationButtons(sectionIdentifier),
            if (answerSubmitted) ...[
              SizedBox(height: 24),
              _buildFeedback(correctAnswer, choices),
            ],
          ],
        ),
      ),
    );
  }

  Widget _handleEmptyQuizCards() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/resource_screen',
          arguments: widget.docId);
    });

    return Center(
      child: Text(
          'No quiz cards available for this section. Returning to the previous screen...'),
    );
  }

  int _getSectionIdentifier(Map<String, dynamic> currentCard) {
    return (currentCard['section_identifier'] is int)
        ? currentCard['section_identifier']
        : (currentCard['section_identifier'] as double).toInt();
  }

  Widget _buildQuestion(String question) {
    return MarkdownBody(
      data: question,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  List<Widget> _buildChoices(
      Map<String, dynamic> choices, String correctAnswer) {
    return choices.entries
        .map((choice) => RadioListTile(
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
                  ? (choice.key == correctAnswer ? Colors.green : Colors.red)
                  : Theme.of(context).primaryColor,
            ))
        .toList();
  }

  Widget _buildNavigationButtons(int sectionIdentifier) {
    return Row(
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        ),
        ElevatedButton(
          onPressed: selectedAnswer != null && !answerSubmitted
              ? () {
                  setState(() {
                    answerSubmitted = true;
                    if (selectedAnswer ==
                        quizCards[currentCardIndex]['correct_answer']) {
                      correctAnswers++;
                    }
                  });
                }
              : null,
          child: Text('Submit'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
        ElevatedButton(
          onPressed: answerSubmitted
              ? () => _handleNextOrFinish(sectionIdentifier)
              : null,
          child:
              Text(currentCardIndex < quizCards.length - 1 ? 'Next' : 'Finish'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
      ],
    );
  }

  void _handleNextOrFinish(int sectionIdentifier) {
    if (currentCardIndex < quizCards.length - 1) {
      setState(() {
        currentCardIndex++;
        selectedAnswer = null;
        answerSubmitted = false;
      });
    } else {
      if (currentSectionIndex < sectionIdentifier) {
        FirebaseFirestore.instance
            .collection('user1')
            .doc(widget.docId)
            .update({'currentSectionIndex': sectionIdentifier});
      }
      Navigator.pushReplacementNamed(context, '/resource_screen',
          arguments: widget.docId);
      widget.onQuizComplete?.call(correctAnswers, sectionIdentifier);
    }
  }

  Widget _buildFeedback(String correctAnswer, Map<String, dynamic> choices) {
    return Text(
      selectedAnswer == correctAnswer
          ? 'Correct!'
          : 'Incorrect. The correct answer is: ${choices[correctAnswer]}',
      style: TextStyle(
        color: selectedAnswer == correctAnswer ? Colors.green : Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
