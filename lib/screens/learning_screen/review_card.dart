import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myapp/design/animated_button';
import 'package:myapp/design/ui_colors.dart';
import 'package:myapp/design/ui_fonts.dart';
import 'package:myapp/design/ui_icons.dart';
import 'package:myapp/design/ui_values.dart';
import 'quiz_card.dart';

class ReviewCard extends StatefulWidget {
  final String docId;
  final String sectionTitle;
  final int sectionIdentifier;

  const ReviewCard({
    Key? key,
    required this.docId,
    required this.sectionTitle,
    required this.sectionIdentifier,
  }) : super(key: key);

  @override
  _ReviewCardState createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool showAnswer = false;
  int currentCardIndex = 0;
  List<Map<String, dynamic>> reviewCards = [];

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: UIColors.accentColor,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(UiValues.defaultBorderRadius * 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              widget.sectionTitle,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: UIFonts.fontBold,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
                color: Colors.white,
              ),
              maxLines: 3,
            ),
          ),
          SizedBox(width: 16),
          AnimatedButton(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(UiValues.defaultBorderRadius),
              child: Image.asset(
                UiAssets.resourceScreenHeaderBGDefault,
                height: 64,
                width: 64,
                fit: BoxFit.cover,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: StreamBuilder<DocumentSnapshot>(
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

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(UiValues.defaultBorderRadius * 2),
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
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
                            styleSheet:
                                MarkdownStyleSheet.fromTheme(Theme.of(context))
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
                              styleSheet: MarkdownStyleSheet.fromTheme(
                                      Theme.of(context))
                                  .copyWith(
                                p: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                  '${currentCardIndex + 1} / ${reviewCards.length}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedButton(
                        onTap: currentCardIndex > 0
                            ? () {
                                setState(() {
                                  currentCardIndex--;
                                  showAnswer = false;
                                });
                              }
                            : () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          width: 112,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: UIColors.secondaryBGColor,
                            borderRadius: BorderRadius.circular(
                                UiValues.defaultBorderRadius),
                          ),
                          child: const Text(
                            "Previous",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: UIFonts.fontBold,
                                fontWeight: FontWeight.bold,
                                color: UIColors.subHeaderColor),
                          ),
                        ),
                      ),
                      AnimatedButton(
                        onTap: () {
                          setState(() {
                            showAnswer = !showAnswer;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          width: 112,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: UIColors.secondaryColor,
                            borderRadius: BorderRadius.circular(
                                UiValues.defaultBorderRadius),
                          ),
                          child: Text(
                            showAnswer ? 'Hide Answer' : 'Show Answer',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18,
                                fontFamily: UIFonts.fontBold,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      AnimatedButton(
                        onTap: () {
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
                                  sectionIdentifier: widget.sectionIdentifier,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          width: 112,
                          height: 48,
                          decoration: BoxDecoration(
                            color: UIColors.secondaryColor,
                            borderRadius: BorderRadius.circular(
                                UiValues.defaultBorderRadius),
                          ),
                          child: Text(
                            currentCardIndex < reviewCards.length - 1
                                ? 'Next'
                                : 'Take Quiz',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18,
                                fontFamily: UIFonts.fontBold,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: UIColors.errorColor,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: AnimatedButton(
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 32),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
