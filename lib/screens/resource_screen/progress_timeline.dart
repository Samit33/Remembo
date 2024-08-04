import 'package:flutter/material.dart';
import 'package:myapp/design/animated_button';
import 'package:myapp/design/ui_colors.dart';
import 'package:myapp/design/ui_fonts.dart';
import 'package:myapp/design/ui_values.dart';
import '../learning_screen/learning_card.dart';

class ProgressTimeline extends StatelessWidget {
  final List<String> sectionTitles;
  final String docId;
  final int currentSectionIdentifier;
  static const double sectionHeightDefault = 16;
  static const double sectionHeightSelected = 24;

  const ProgressTimeline({
    super.key,
    required this.sectionTitles,
    required this.docId,
    required this.currentSectionIdentifier,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 32,
          top: sectionHeightDefault * 3,
          bottom: 0,
          child: CustomPaint(
            painter: _VerticalFillMeterPainter(
              sectionCount: sectionTitles.length,
              completedSections: currentSectionIdentifier - 1,
            ),
            child: SizedBox(
              width: 20,
              height: (sectionTitles.length - 1) * sectionHeightDefault +
                  sectionHeightSelected, // Adjust based on your item height
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          padding:
              const EdgeInsets.only(left: 64, right: 16, top: 8, bottom: 16),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sectionTitles.length,
          itemBuilder: (context, index) {
            bool isCurrent = index == (currentSectionIdentifier - 1);
            bool isCompleted = index < (currentSectionIdentifier - 1);

            return Padding(
              padding: EdgeInsets.symmetric(
                  vertical:
                      isCurrent ? sectionHeightSelected : sectionHeightDefault),
              child: AnimatedButton(
                onTap: () {
                  if (isCompleted || isCurrent) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LearningCard(
                          docId: docId,
                          sectionTitle: sectionTitles[index],
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(
                      isCurrent ? sectionHeightSelected : sectionHeightDefault),
                  decoration: BoxDecoration(
                    boxShadow: [UIColors.lighterDropShadow],
                    color: isCurrent
                        ? UIColors.accentColor
                        : isCompleted
                            ? UIColors.secondaryColorLight
                            : Colors.grey[300],
                    borderRadius:
                        BorderRadius.circular(UiValues.defaultBorderRadius),
                  ),
                  child: Text(
                    sectionTitles[index],
                    style: TextStyle(
                      fontFamily: UIFonts.fontBold,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent
                          ? Colors.white
                          : isCompleted
                              ? UIColors.secondaryColor
                              : UIColors.headerColor.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _VerticalFillMeterPainter extends CustomPainter {
  final int sectionCount;
  final int completedSections;

  _VerticalFillMeterPainter({
    required this.sectionCount,
    required this.completedSections,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = UIColors.primaryColor.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = UIColors.primaryColor
      ..style = PaintingStyle.fill;

    final double sectionHeight =
        (size.height + ProgressTimeline.sectionHeightDefault) / sectionCount;
    final double fillHeight = sectionHeight * completedSections;

    // Draw the vertical line
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, size.height),
      paint,
    );

    // Draw the fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 2, fillHeight),
      fillPaint,
    );

    // Draw circles for each section
    for (int i = 0; i < sectionCount; i++) {
      final yPosition = i * sectionHeight;
      final isCompleted = i < completedSections;

      canvas.drawCircle(
        Offset(0, yPosition),
        10,
        Paint()..color = UIColors.primaryColor,
      );

      canvas.drawCircle(
        Offset(0, yPosition),
        8,
        Paint()..color = Colors.white,
      );

      canvas.drawCircle(
        Offset(0, yPosition),
        7,
        Paint()..color = isCompleted ? UIColors.primaryColor : Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
