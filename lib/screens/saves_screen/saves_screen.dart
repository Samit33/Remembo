import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_tabs.dart';
import 'saved_items.dart';
import 'search_bar.dart';
import 'bottom_navbar.dart';


class SavesScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9C91FC), Color(0xFF6952F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saves',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFFBFB7F4),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            NetworkImage('https://example.com/placeholder.jpg'),
                      ),
                    ),
                  ],
                ),
              ),
              CategoryTabs(),
              SearchBarCustom(),
              Expanded(
                child: SavedItemsList(firestore: firestore),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
