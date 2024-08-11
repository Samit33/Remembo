import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myapp/design/animated_button';
import 'package:myapp/design/ui_colors.dart';
import 'package:myapp/design/ui_fonts.dart';
import 'package:myapp/design/ui_icons.dart';
import 'package:myapp/design/ui_values.dart';

class QuizCard extends StatefulWidget {
  final String docId;
  final String sectionTitle;
  final int sectionIdentifier;

  const QuizCard({
    Key? key,
    required this.docId,
    required this.sectionTitle,
    required this.sectionIdentifier,
  }) : super(key: key);

  @override
  _QuizCardState createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  int currentCardIndex = 0;
  List<Map<String, dynamic>> quizCards = [];
  String? selectedAnswer;
  bool answerSubmitted = false;
  late Future<void> _quizDataFuture;

  @override
  void initState() {
    super.initState();
    _quizDataFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user1')
        .doc(widget.docId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      List<Map<String, dynamic>> fetchedQuizCards =
          (data?['quiz_cards']?['args']?['quiz_cards'] as List?)
                  ?.map((card) => card as Map<String, dynamic>)
                  .toList() ??
              [];

      fetchedQuizCards = fetchedQuizCards
          .where((card) => card['section_title'] == widget.sectionTitle)
          .toList();

      setState(() {
        quizCards = fetchedQuizCards;
      });
    }
  }

  void _updateCurrentSectionIdentifier() {
    if (widget.sectionIdentifier < widget.sectionIdentifier + 1) {
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
              'Quiz: ${widget.sectionTitle}',
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
              UiAssets.quizCardIcon,
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

  Widget _buildQuizOption(String key, String value, String correctAnswer) {
    Color optionColor = Colors.white;
    Color textColor = UIColors.subHeaderColor;
    Color borderColor = Colors.transparent;
    double borderWidth = 0;

    if (answerSubmitted) {
      if (key == correctAnswer) {
        optionColor = UIColors.secondaryColor;
        textColor = Colors.white;
      } else if (key == selectedAnswer) {
        optionColor = UIColors.errorColor;
        textColor = Colors.white;
      } else {
        optionColor = UIColors.disabledColor;
      }
    } else if (key == selectedAnswer) {
      borderColor = UIColors.accentColor;
      borderWidth = 3.0;
    }

    return AnimatedButton(
      onTap: answerSubmitted
          ? () {}
          : () {
              setState(() {
                selectedAnswer = key;
              });
            },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: optionColor,
          borderRadius: BorderRadius.circular(UiValues.defaultBorderRadius),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          boxShadow: const [
            UIColors.dropShadow,
          ],
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontFamily: UIFonts.fontRegular,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(List<Map<String, dynamic>> quizCards) {
    return Padding(
      padding: const EdgeInsets.all(UiValues.defaultPadding * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (currentCardIndex > 0)
            Expanded(
              child: _buildNavigationButton(
                "Previous",
                UIColors.secondaryBGColor,
                UIColors.subHeaderColor,
                currentCardIndex > 0
                    ? () {
                        setState(() {
                          currentCardIndex--;
                          selectedAnswer = null;
                          answerSubmitted = false;
                        });
                      }
                    : null,
              ),
            ),
          if (quizCards.length > 1) const SizedBox(width: 16),
          if (!answerSubmitted)
            Expanded(
              child: _buildNavigationButton(
                "Submit",
                selectedAnswer != null ? UIColors.accentColor : Colors.grey,
                Colors.white,
                selectedAnswer != null
                    ? () {
                        setState(() {
                          answerSubmitted = true;
                        });
                      }
                    : null,
              ),
            ),
          if (answerSubmitted)
            Expanded(
              child: _buildNavigationButton(
                currentCardIndex < quizCards.length - 1 ? 'Next' : 'Finish',
                UIColors.secondaryColor,
                Colors.white,
                answerSubmitted
                    ? () {
                        if (currentCardIndex < quizCards.length - 1) {
                          setState(() {
                            currentCardIndex++;
                            selectedAnswer = null;
                            answerSubmitted = false;
                          });
                        } else {
                          _updateCurrentSectionIdentifier();
                          Navigator.pushReplacementNamed(
                            context,
                            '/resource_screen',
                            arguments: widget.docId,
                          );
                        }
                      }
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
      String text, Color bgColor, Color textColor, VoidCallback? onTap) {
    return AnimatedButton(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(UiValues.defaultBorderRadius),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontFamily: UIFonts.fontBold,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: UIColors.errorColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Align(
        alignment: Alignment.center,
        child: AnimatedButton(
          child: const Icon(Icons.close, color: Colors.white, size: 32),
          onTap: () {
            Navigator.pop(context);
          },
        ),
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
        future: _quizDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (quizCards.isEmpty) {
            return const Center(
              child: Text(
                  'No quiz cards available for this section. Returning to the previous screen...'),
            );
          }

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
                          bottom:
                              Radius.circular(UiValues.defaultBorderRadius * 2),
                          top:
                              Radius.circular(UiValues.defaultBorderRadius * 2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    UiValues.defaultPadding * 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    MarkdownBody(
                                      data: quizCards[currentCardIndex]['Q'] ??
                                          'No question available',
                                      styleSheet: MarkdownStyleSheet.fromTheme(
                                              Theme.of(context))
                                          .copyWith(
                                        p: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: UIFonts.fontBold,
                                          fontWeight: FontWeight.bold,
                                          color: UIColors.headerColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ...quizCards[currentCardIndex]['choices']
                                        .entries
                                        .map((choice) => _buildQuizOption(
                                              choice.key,
                                              choice.value,
                                              quizCards[currentCardIndex]
                                                  ['correct_answer'],
                                            )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildBottomButtons(quizCards),
                          _buildCloseButton(),
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
