import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String tag;

  const TagChip({Key? key, required this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(tag),
      backgroundColor: Colors.green.shade100,
    );
  }
}
