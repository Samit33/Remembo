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
  int currentCardIndex = 0;
  List<Map<String, dynamic>> reviewCards = [];
  bool showAnswer = false;
  late Future<void> _reviewDataFuture;

  @override
  void initState() {
    super.initState();
    _reviewDataFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user1')
        .doc(widget.docId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      List<Map<String, dynamic>> fetchedReviewCards =
          (data?['review_cards']?['args']?['review_cards'] as List?)
                  ?.map((card) => card as Map<String, dynamic>)
                  .toList() ??
              [];

      fetchedReviewCards = fetchedReviewCards
          .where((card) => card['section_title'] == widget.sectionTitle)
          .toList();

      setState(() {
        reviewCards = fetchedReviewCards;
      });
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(UiValues.defaultBorderRadius * 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Review: ${widget.sectionTitle}',
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
            child: Image.asset(
              UiAssets.reviewCardIcon,
              height: 48,
              width: 48,
              fit: BoxFit.cover,
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
      insetPadding: const EdgeInsets.fromLTRB(
          UiValues.defaultPadding,
          UiValues.defaultPadding * 2,
          UiValues.defaultPadding,
          UiValues.defaultPadding * 2),
      child: FutureBuilder<void>(
        future: _reviewDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (reviewCards.isEmpty) {
            return const Center(
                child: Text('No review cards available for this section'));
          }

          Map<String, dynamic> currentCard = reviewCards[currentCardIndex];
          String question = currentCard['Q'] ?? 'No question available';
          String answer = currentCard['A'] ?? 'No answer available';

          return Container(
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      UIColors.primaryGradientColor1,
                      UIColors.primaryGradientColor2
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(UiValues.defaultBorderRadius * 2)),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top:
                              Radius.circular(UiValues.defaultBorderRadius * 2),
                          bottom:
                              Radius.circular(UiValues.defaultBorderRadius * 2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    MarkdownBody(
                                      data: question,
                                      styleSheet: MarkdownStyleSheet.fromTheme(
                                              Theme.of(context))
                                          .copyWith(
                                        p: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    if (showAnswer) ...[
                                      const Divider(),
                                      SizedBox(height: 8),
                                      MarkdownBody(
                                        data: answer,
                                        styleSheet:
                                            MarkdownStyleSheet.fromTheme(
                                                    Theme.of(context))
                                                .copyWith(
                                          p: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (currentCardIndex > 0)
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
                                      showAnswer ? 'Hide' : 'Show',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
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
                                    if (currentCardIndex <
                                        reviewCards.length - 1) {
                                      setState(() {
                                        currentCardIndex++;
                                        showAnswer = false;
                                      });
                                    } else {
                                      Navigator.pop(context);

                                      showGeneralDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        barrierLabel:
                                            MaterialLocalizations.of(context)
                                                .modalBarrierDismissLabel,
                                        barrierColor: Colors.black45,
                                        transitionDuration:
                                            const Duration(milliseconds: 250),
                                        pageBuilder: (BuildContext buildContext,
                                            Animation<double> animation,
                                            Animation secondaryAnimation) {
                                          return ScaleTransition(
                                            scale: CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.elasticInOut,
                                            ),
                                            child: QuizCard(
                                              docId: widget.docId,
                                              sectionTitle: widget.sectionTitle,
                                              sectionIdentifier:
                                                  widget.sectionIdentifier,
                                            ),
                                          );
                                        },
                                      );
                                      //close the review card dialog
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
                            decoration: const BoxDecoration(
                              color: UIColors.errorColor,
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(20)),
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
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }
}
