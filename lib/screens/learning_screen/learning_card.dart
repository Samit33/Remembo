import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user1')
          .doc(widget.docId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> fetchedCards =
            (data['learning_cards']?['args']?['cards'] as List?)
                    ?.map((card) => card as Map<String, dynamic>)
                    .toList() ??
                [];

        setState(() {
          cards = fetchedCards
              .where((card) => card['section_title'] == widget.sectionTitle)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No data available';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error: $error';
        isLoading = false;
      });
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UiValues.defaultBorderRadius * 2),
        ),
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
            child: Image.asset(
              UiAssets.learningCardIcon,
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
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (cards.isEmpty) {
      return Center(child: Text('No cards found for this section'));
    }

    Map<String, dynamic> currentCard = cards[currentCardIndex];
    String cardTitle = currentCard['card_title'] ?? 'No Title';
    String content = currentCard['content'] ?? 'No Content';

    int sectionIdentifier = (currentCard['section_identifier'] is int)
        ? currentCard['section_identifier']
        : (currentCard['section_identifier'] as double).toInt();

    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.fromLTRB(
            UiValues.defaultPadding,
            UiValues.defaultPadding * 2,
            UiValues.defaultPadding,
            UiValues.defaultPadding * 2),
        child: Container(
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
                BorderRadius.circular(UiValues.defaultBorderRadius * 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: UiValues.defaultElevation,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(UiValues.defaultBorderRadius * 2),
                        bottom:
                            Radius.circular(UiValues.defaultBorderRadius * 2)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.all(UiValues.defaultPadding * 1.5),
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
                            padding: const EdgeInsets.all(
                                UiValues.defaultPadding * 1.5),
                            child: MarkdownBody(
                              data: content,
                              styleSheet: MarkdownStyleSheet.fromTheme(
                                      Theme.of(context))
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (currentCardIndex > 0)
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
                                  Navigator.of(context).pop();
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
                                        child: ReviewCard(
                                          docId: widget.docId,
                                          sectionTitle: widget.sectionTitle,
                                          sectionIdentifier: sectionIdentifier,
                                        ),
                                      );
                                    },
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
          ),
        ));
  }
}
