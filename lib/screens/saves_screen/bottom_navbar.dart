// bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'add_url_dialog.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, isActive: true),
          _buildNavItem(Icons.list),
          _buildNavItem(Icons.info_outline),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, {bool isActive = false}) {
    return Icon(
      icon,
      color: isActive ? Colors.green : Colors.grey,
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddUrlDialog(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showAddUrlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddUrlDialog(
          onSave: (url) {
            // TODO: Implement save functionality
            print('URL to save: $url');
          },
        );
      },
    );
  }
}