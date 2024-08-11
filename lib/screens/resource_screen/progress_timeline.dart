import 'package:flutter/material.dart';
import 'package:myapp/design/animated_button';
import 'package:myapp/design/ui_colors.dart';
import 'package:myapp/design/ui_fonts.dart';
import 'package:myapp/design/ui_values.dart';
import '../learning_screen/learning_card.dart';

class ProgressTimeline extends StatefulWidget {
  final List<String> sectionTitles;
  final String docId;
  final int currentSectionIdentifier;
  static const double sectionHeightDefault = 16.0;
  static const double sectionHeightSelected = 24.0;

  const ProgressTimeline({
    super.key,
    required this.sectionTitles,
    required this.docId,
    required this.currentSectionIdentifier,
  });

  @override
  _ProgressTimelineState createState() => _ProgressTimelineState();
}

class _ProgressTimelineState extends State<ProgressTimeline>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = IntTween(begin: 2, end: widget.sectionTitles.length)
        .animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    Future.delayed(const Duration(microseconds: 500), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            _buildVerticalFillMeter(constraints),
            _buildSectionList(constraints),
          ],
        );
      },
    );
  }

  Widget _buildVerticalFillMeter(BoxConstraints constraints) {
    return Positioned(
      left: 32,
      top: 0,
      bottom: 0,
      child: CustomPaint(
        painter: _VerticalFillMeterPainter(
          sectionCount: widget.sectionTitles.length,
          completedSections: _animation.value - 1,
          sectionPositions: List.generate(widget.sectionTitles.length, (index) {
            return (index * (ProgressTimeline.sectionHeightDefault * 4 + 16)) +
                ProgressTimeline.sectionHeightDefault * 3;
          }),
        ),
        child: SizedBox(
          width: 20,
          height: constraints.maxHeight,
        ),
      ),
    );
  }

  Widget _buildSectionList(BoxConstraints constraints) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 64, right: 16, top: 0, bottom: 16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.sectionTitles.length,
      itemBuilder: (context, index) {
        bool isCurrent = index == (_animation.value - 1);
        bool isCompleted = index < (_animation.value - 1);

        return Padding(
          padding: const EdgeInsets.symmetric(
              vertical: ProgressTimeline.sectionHeightDefault),
          child: AnimatedButton(
            onTap: () {
              if (isCompleted || isCurrent) {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: MaterialLocalizations.of(context)
                      .modalBarrierDismissLabel,
                  barrierColor: Colors.black45,
                  transitionDuration: const Duration(milliseconds: 250),
                  pageBuilder: (BuildContext buildContext,
                      Animation<double> animation,
                      Animation secondaryAnimation) {
                    return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.elasticInOut,
                        ),
                        child: LearningCard(
                          docId: widget.docId,
                          sectionTitle: widget.sectionTitles[index],
                        ));
                  },
                );
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.all(ProgressTimeline.sectionHeightDefault),
              decoration: BoxDecoration(
                boxShadow: const [UIColors.lighterDropShadow],
                color: isCurrent
                    ? UIColors.primaryGradientColor1
                    : isCompleted
                        ? Colors.white
                        : Colors.grey[300],
                borderRadius:
                    BorderRadius.circular(UiValues.defaultBorderRadius),
              ),
              child: Text(
                widget.sectionTitles[index],
                style: TextStyle(
                  fontFamily: UIFonts.fontBold,
                  fontSize: 16,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
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
    );
  }
}

class _VerticalFillMeterPainter extends CustomPainter {
  final int sectionCount;
  final int completedSections;
  final List<double> sectionPositions;

  _VerticalFillMeterPainter({
    required this.sectionCount,
    required this.completedSections,
    required this.sectionPositions,
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

    // Draw the vertical line
    canvas.drawLine(
      Offset(0, sectionPositions.first),
      Offset(0, sectionPositions.last),
      paint,
    );

    // Draw the fill
    if (completedSections > 0) {
      double fillEnd = completedSections < sectionCount
          ? sectionPositions[completedSections]
          : sectionPositions.last;
      canvas.drawRect(
        Rect.fromLTRB(0, sectionPositions.first, 2, fillEnd),
        fillPaint,
      );
    }

    // Draw circles for each section
    for (int i = 0; i < sectionCount; i++) {
      final isCompleted = i < completedSections;

      canvas.drawCircle(
        Offset(0, sectionPositions[i]),
        10,
        Paint()..color = UIColors.primaryColor,
      );

      canvas.drawCircle(
        Offset(0, sectionPositions[i]),
        8,
        Paint()..color = Colors.white,
      );

      canvas.drawCircle(
        Offset(0, sectionPositions[i]),
        7,
        Paint()..color = isCompleted ? UIColors.primaryColor : Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalFillMeterPainter oldDelegate) =>
      oldDelegate.completedSections != completedSections ||
      oldDelegate.sectionPositions != sectionPositions;
}
