import 'package:flutter/material.dart';

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
          _buildAddButton(),
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

  Widget _buildAddButton() {
    return Container(
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
    );
  }
}
