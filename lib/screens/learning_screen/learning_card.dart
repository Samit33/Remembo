import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myapp/design/animated_button';
import 'package:myapp/design/animated_button';
import 'package:myapp/design/ui_colors.dart';
import 'package:myapp/design/ui_fonts.dart';
import 'package:myapp/design/ui_icons.dart';
import 'package:myapp/design/ui_values.dart';
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
                  color: Colors.white),
              maxLines: 3,
              // Remove maxLines and overflow to allow wrapping
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
                fit: BoxFit.cover, // Adjust the height as needed
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
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(UiValues.defaultBorderRadius * 2),
            ),
            child: Column(
              //mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    cardTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: UIFonts.fontBold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: MarkdownBody(
                        data: content,
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(Theme.of(context))
                                .copyWith(
                          p: TextStyle(fontSize: 16),
                          h1: TextStyle(fontSize: 20),
                          h2: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  '${currentCardIndex + 1} / ${cards.length}',
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
                                });
                              }
                            : () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          width: 172,
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
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          width: 172,
                          height: 48,
                          decoration: BoxDecoration(
                            color: UIColors.secondaryColor,
                            borderRadius: BorderRadius.circular(
                                UiValues.defaultBorderRadius),
                          ),
                          child: Text(
                            currentCardIndex < cards.length - 1
                                ? 'Next'
                                : 'Begin Review',
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
                // Footer with close button
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
