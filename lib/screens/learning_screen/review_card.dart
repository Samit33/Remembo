import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'quiz_card.dart';

class ReviewCard extends StatefulWidget {
  final String docId;
  final String sectionTitle;
  final Function() onReviewComplete;

  const ReviewCard({
    Key? key,
    required this.docId,
    required this.sectionTitle,
    required this.onReviewComplete,
  }) : super(key: key);

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool showAnswer = false;
  int currentCardIndex = 0;
  List<Map<String, dynamic>> reviewCards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sectionTitle),
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
          reviewCards =
              (data['review_cards']?['args']?['review_cards'] as List?)
                      ?.map((card) => card as Map<String, dynamic>)
                      .toList() ??
                  [];

          reviewCards = reviewCards
              .where((card) => card['section_title'] == widget.sectionTitle)
              .toList();

          if (reviewCards.isEmpty) {
            return Center(
                child: Text('No review cards available for this section'));
          }

          Map<String, dynamic> currentCard = reviewCards[currentCardIndex];
          String question = currentCard['Q'] ?? 'No question available';
          String answer = currentCard['A'] ?? 'No answer available';

          // Convert section_identifier to int, handling potential double values
          int sectionIdentifier = (currentCard['section_identifier'] is int)
              ? currentCard['section_identifier']
              : (currentCard['section_identifier'] as double).toInt();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  MarkdownBody(
                    data: question,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                      p: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SizedBox(height: 24),
                  if (showAnswer) ...[
                    Text(
                      'Answer:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    MarkdownBody(
                      data: answer,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(Theme.of(context))
                              .copyWith(
                        p: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: currentCardIndex > 0
                            ? () {
                                setState(() {
                                  currentCardIndex--;
                                  showAnswer = false;
                                });
                              }
                            : null,
                        child: Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showAnswer = !showAnswer;
                          });
                        },
                        child: Text(showAnswer ? 'Hide Answer' : 'Show Answer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (currentCardIndex < reviewCards.length - 1) {
                            setState(() {
                              currentCardIndex++;
                              showAnswer = false;
                            });
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizCard(
                                  docId: widget.docId,
                                  sectionTitle: widget.sectionTitle,
                                  onQuizComplete:
                                      (score, quizSectionIdentifier) {
                                    widget.onReviewComplete();
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(currentCardIndex < reviewCards.length - 1
                            ? 'Next'
                            : 'Take Quiz'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
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
}
