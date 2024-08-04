import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'review_card.dart';

class LearningCard extends StatefulWidget {
  final String docId;
  final String sectionTitle;

  const LearningCard({
    Key? key,
    required this.docId,
    required this.sectionTitle,
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

          int sectionIdentifier = (currentCard['section_identifier'] is int)
              ? currentCard['section_identifier']
              : (currentCard['section_identifier'] as double).toInt();

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple[50]!, Colors.indigo[100]!],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          widget.sectionTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(width: 48), // To balance the close button
                      ],
                    ),
                    SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (currentCardIndex + 1) / cards.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                    SizedBox(height: 24),
                    Expanded(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cardTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.purple[800],
                                      fontWeight: FontWeight.bold,
                                    ),
                                overflow: TextOverflow
                                    .ellipsis, // Added to handle overflow
                                maxLines: 1, // Limit to one line
                              ),
                              SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: MarkdownBody(
                                    data: content,
                                    styleSheet: MarkdownStyleSheet.fromTheme(
                                            Theme.of(context))
                                        .copyWith(
                                      p: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(height: 1.5),
                                      h1: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                      h2: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.arrow_back),
                          label: Text('Previous'),
                          onPressed: currentCardIndex > 0
                              ? () {
                                  setState(() {
                                    currentCardIndex--;
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor:
                                Colors.black, // Changed back to onPrimary
                          ),
                        ),
                        Text(
                          '${currentCardIndex + 1} / ${cards.length}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          icon: Icon(currentCardIndex < cards.length - 1
                              ? Icons.arrow_forward
                              : Icons.check),
                          label: Text(currentCardIndex < cards.length - 1
                              ? 'Next'
                              : 'Start Review'),
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
                                    sectionIdentifier: sectionIdentifier,
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor:
                                Colors.white, // Changed back to onPrimary
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
