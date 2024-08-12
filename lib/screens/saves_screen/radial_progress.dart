import 'package:flutter/material.dart';
import 'package:myapp/design/ui_colors.dart';

class RadialProgressWidget extends StatelessWidget {
  final double progress;

  const RadialProgressWidget({Key? key, required this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          CustomPaint(
            painter: GradientCircularProgressPainter(progress),
            child: Center(
              child: Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  final double progress;

  GradientCircularProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the background circle
    Paint backgroundPaint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..color = Colors.grey[300]!;

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      0,
      3.14 * 2,
      false,
      backgroundPaint,
    );

    // Draw the progress arc with gradient
    Paint progressPaint = Paint()
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..shader = SweepGradient(
        colors: [Colors.blue, Colors.green],
        startAngle: 0.0,
        endAngle: 3.14 * 2,
      ).createShader(Rect.fromCircle(
          center: size.center(Offset.zero), radius: size.width / 2));

    double startAngle = -3.14 / 2; // Start at the top
    double sweepAngle = 3.14 * 2 * progress; // Sweep angle based on progress

    canvas.drawArc(
      Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// For Video Purpose Only

// class AnimatedRadialProgressWidget extends StatefulWidget {
//   @override
//   _AnimatedRadialProgressWidgetState createState() =>
//       _AnimatedRadialProgressWidgetState();
// }

// class _AnimatedRadialProgressWidgetState
//     extends State<AnimatedRadialProgressWidget>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 40,
//       height: 40,
//       child: AnimatedBuilder(
//         animation: _animation,
//         builder: (context, child) {
//           return CustomPaint(
//             painter: GradientCircularProgressPainter(_animation.value),
//             child: Center(
//               child: Text(
//                 '${(_animation.value * 100).toInt()}%',
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class GradientCircularProgressPainter extends CustomPainter {
//   final double progress;

//   GradientCircularProgressPainter(this.progress);

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Draw the background circle
//     Paint backgroundPaint = Paint()
//       ..strokeWidth = 4
//       ..style = PaintingStyle.stroke
//       ..color = Colors.grey[300]!;

//     canvas.drawArc(
//       Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
//       0,
//       3.14 * 2,
//       false,
//       backgroundPaint,
//     );

//     // Draw the progress arc with gradient
//     Paint progressPaint = Paint()
//       ..strokeWidth = 4
//       ..style = PaintingStyle.stroke
//       ..shader = SweepGradient(
//         colors: [
//           UIColors.secondaryGradientColor1,
//           UIColors.secondaryGradientColor2
//         ],
//         startAngle: 0.0,
//         endAngle: 3.14 * 2,
//       ).createShader(Rect.fromCircle(
//           center: size.center(Offset.zero), radius: size.width / 2));

//     double startAngle = -3.14 / 2; // Start at the top
//     double sweepAngle = 3.14 * 2 * progress; // Sweep angle based on progress

//     canvas.drawArc(
//       Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2),
//       startAngle,
//       sweepAngle,
//       false,
//       progressPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
