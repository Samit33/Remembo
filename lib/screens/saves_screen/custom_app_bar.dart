import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.deepPurple,
      elevation: 0,
      title: const Text(
        'Saves',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
