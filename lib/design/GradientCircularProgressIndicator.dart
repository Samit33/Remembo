import 'dart:math';
import 'package:flutter/material.dart';

class GradientCircularProgressIndicator extends StatefulWidget {
  final double radius;
  final List<Color> colors;
  final double strokeWidth;

  const GradientCircularProgressIndicator({
    Key? key,
    required this.radius,
    required this.colors,
    this.strokeWidth = 4.0,
  }) : super(key: key);

  @override
  _GradientCircularProgressIndicatorState createState() =>
      _GradientCircularProgressIndicatorState();
}

class _GradientCircularProgressIndicatorState
    extends State<GradientCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientCircularProgressPainter(
            progress: _animation.value,
            radius: widget.radius,
            colors: widget.colors,
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double radius;
  final List<Color> colors;
  final double strokeWidth;

  _GradientCircularProgressPainter({
    required this.progress,
    required this.radius,
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    final gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * pi,
      colors: colors,
      stops: [0.0, progress],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = this.radius - strokeWidth / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
