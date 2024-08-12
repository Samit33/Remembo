import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:remembo/design/animated_button';
import 'package:remembo/design/ui_colors.dart';
import 'package:remembo/design/ui_fonts.dart';
import 'package:remembo/design/ui_icons.dart';
import 'package:remembo/design/ui_values.dart';

class ComprehensiveQuizScreen extends StatefulWidget {
  final String docId;
  final int totalQuestions;
  final Function(int) onQuizComplete;

  const ComprehensiveQuizScreen({
    Key? key,
    required this.docId,
    required this.totalQuestions,
    required this.onQuizComplete,
  }) : super(key: key);

  @override
  _ComprehensiveQuizScreenState createState() =>
      _ComprehensiveQuizScreenState();
}

class _ComprehensiveQuizScreenState extends State<ComprehensiveQuizScreen> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> quizQuestions = [];
  String? selectedAnswer;
  int score = 0;
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
      List<Map<String, dynamic>> fetchedQuizQuestions =
          (data?['quiz_cards']?['args']?['quiz_cards'] as List?)
                  ?.map((card) => card as Map<String, dynamic>)
                  .toList() ??
              [];

      setState(() {
        quizQuestions = fetchedQuizQuestions;
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
              'Comprehensive Quiz',
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

    if (selectedAnswer != null) {
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
      onTap: selectedAnswer != null
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

  Widget _buildBottomButtons(List<Map<String, dynamic>> quizQuestions) {
    return Padding(
      padding: const EdgeInsets.all(UiValues.defaultPadding * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (currentQuestionIndex > 0)
            Expanded(
              child: _buildNavigationButton(
                "Previous",
                UIColors.secondaryBGColor,
                UIColors.subHeaderColor,
                currentQuestionIndex > 0
                    ? () {
                        setState(() {
                          currentQuestionIndex--;
                          selectedAnswer = null;
                        });
                      }
                    : null,
              ),
            ),
          if (quizQuestions.length > 1) const SizedBox(width: 16),
          if (selectedAnswer != null)
            Expanded(
              child: _buildNavigationButton(
                currentQuestionIndex < quizQuestions.length - 1
                    ? 'Next'
                    : 'Finish',
                UIColors.secondaryColor,
                Colors.white,
                selectedAnswer != null
                    ? () {
                        if (selectedAnswer ==
                            quizQuestions[currentQuestionIndex]
                                ['correct_answer']) {
                          score++;
                        }
                        if (currentQuestionIndex < quizQuestions.length - 1) {
                          setState(() {
                            currentQuestionIndex++;
                            selectedAnswer = null;
                          });
                        } else {
                          _finishQuiz();
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

  void _finishQuiz() async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(
          FirebaseFirestore.instance.collection('user1').doc(widget.docId));

      if (!snapshot.exists) {
        throw Exception("Document does not exist!");
      }

      transaction.set(
          FirebaseFirestore.instance.collection('user1').doc(widget.docId),
          {'quizScore': score},
          SetOptions(merge: true));
    });

    widget.onQuizComplete(score);
    Navigator.pop(context);
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

          if (quizQuestions.isEmpty) {
            return const Center(
              child: Text(
                  'No quiz questions available. Returning to the previous screen...'),
            );
          }

          Map<String, dynamic> currentQuestion =
              quizQuestions[currentQuestionIndex];
          String question = currentQuestion['Q'] ?? 'No question available';
          Map<String, dynamic> choices =
              Map.from(currentQuestion['choices'] ?? {});
          String correctAnswer = currentQuestion['correct_answer'] ?? '';

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
                  BorderRadius.circular(UiValues.defaultBorderRadius * 2),
            ),
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
                        top: Radius.circular(UiValues.defaultBorderRadius * 2),
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
                                    data: question,
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
                                  ...choices.entries
                                      .map((choice) => _buildQuizOption(
                                            choice.key,
                                            choice.value,
                                            correctAnswer,
                                          )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildBottomButtons(quizQuestions),
                        _buildCloseButton(),
                      ],
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
