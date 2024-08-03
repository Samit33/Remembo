import 'package:flutter/material.dart';
import 'package:myapp/design/ui_colors.dart';

class GradientSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Gradient gradient;

  const GradientSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.gradient,
  });

  @override
  // ignore: library_private_types_in_public_api
  _GradientSwitchState createState() => _GradientSwitchState();
}

class _GradientSwitchState extends State<GradientSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: Container(
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: widget.gradient,
        ),
        child: Stack(
          children: [
            Positioned(
              left: widget.value ? 20 : 0,
              right: widget.value ? 0 : 20,
              child: Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [UIColors.dropShadow]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
