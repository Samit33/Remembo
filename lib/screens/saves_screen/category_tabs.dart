import 'package:flutter/material.dart';
import 'package:remembo/design/animated_button';

class CategoryTabs extends StatefulWidget {
  const CategoryTabs({Key? key}) : super(key: key);

  @override
  _CategoryTabsState createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTab('All', index: 0),
            _buildTab('Active', index: 1),
            _buildTab('Collections', index: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, {required int index}) {
    final isActive = _activeTabIndex == index;

    return Expanded(
      child: AnimatedButton(
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
                color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 2,
                  color: Colors.white.withOpacity(0.2), // Transparent underline
                ),
                if (isActive)
                  Container(
                    height: 2,
                    alignment: Alignment.center,
                    //width: 100,
                    color: Colors.white, // Solid white underline for active tab
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
