import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C91FC), Color(0xFF6952F0)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavBarIcon(Icons.home_outlined),
          NavBarIcon(Icons.bookmark_border),
          NavBarIcon(Icons.access_time),
          Container(
            width: 52,
            height: 26,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C91FC), Color(0xFF6952F0)],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarIcon extends StatelessWidget {
  final IconData icon;

  NavBarIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Colors.white);
  }
}
