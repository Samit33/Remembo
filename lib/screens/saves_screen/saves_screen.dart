import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_tabs.dart';
import 'custom_app_bar.dart';
import 'saved_items.dart';
import 'search_bar.dart';
import 'bottom_navbar.dart';

class SavesScreen extends StatelessWidget {
  final FirebaseFirestore firestore;

  const SavesScreen({Key? key, required this.firestore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const CategoryTabs(),
          const SearchBarCustom(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SavedItemsList(firestore: firestore),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
