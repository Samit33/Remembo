import 'package:flutter/material.dart';

class CategoryTabs extends StatefulWidget {
  const CategoryTabs({Key? key}) : super(key: key);

  @override
  _CategoryTabsState createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTab('All', index: 0),
          const SizedBox(width: 16),
          _buildTab('Active', index: 1),
          const SizedBox(width: 16),
          _buildTab('Collections', index: 2),
        ],
      ),
    );
  }

  Widget _buildTab(String text, {required int index}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTabIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: _activeTabIndex == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.6),
              fontWeight: _activeTabIndex == index
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (_activeTabIndex == index)
            Container(
              height: 2,
              width: 40,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
