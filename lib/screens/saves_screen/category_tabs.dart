import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CategoryTab('All', isSelected: true),
          CategoryTab('Active'),
          CategoryTab('Collections'),
        ],
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  final String title;
  final bool isSelected;

  CategoryTab(this.title, {this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: isSelected ? Colors.white : Color(0xFFB9AFFF),
        fontSize: 16,
      ),
    );
  }
}
