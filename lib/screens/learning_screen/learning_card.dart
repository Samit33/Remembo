import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'review_card.dart';

class LearningCard extends StatefulWidget {
  final String docId;
  final String sectionTitle;
  final Function(int) onSectionComplete;

  const LearningCard({
    Key? key,
    required this.docId,
    required this.sectionTitle,
    required this.onSectionComplete,
  }) : super(key: key);

  @override
  _LearningCardState createState() => _LearningCardState();
}

class _LearningCardState extends State<LearningCard> {
  int currentCardIndex = 0;
  List<Map<String, dynamic>> cards = [];

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
          cards = (data['learning_cards']?['args']?['cards'] as List?)
                  ?.map((card) => card as Map<String, dynamic>)
                  .toList() ??
              [];

          cards = cards
              .where((card) => card['section_title'] == widget.sectionTitle)
              .toList();

          if (cards.isEmpty) {
            return Center(child: Text('No cards found for this section'));
          }

          Map<String, dynamic> currentCard = cards[currentCardIndex];
          String cardTitle = currentCard['card_title'] ?? 'No Title';
          String content = currentCard['content'] ?? 'No Content';

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
                    cardTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  MarkdownBody(
                    data: content,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                      p: Theme.of(context).textTheme.bodyLarge,
                      h1: Theme.of(context).textTheme.headlineSmall,
                      h2: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: currentCardIndex > 0
                            ? () {
                                setState(() {
                                  currentCardIndex--;
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
                          if (currentCardIndex < cards.length - 1) {
                            setState(() {
                              currentCardIndex++;
                            });
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewCard(
                                  docId: widget.docId,
                                  sectionTitle: widget.sectionTitle,
                                  onReviewComplete: () {
                                    widget.onSectionComplete(sectionIdentifier);
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(currentCardIndex < cards.length - 1
                            ? 'Next'
                            : 'Start Review'),
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
