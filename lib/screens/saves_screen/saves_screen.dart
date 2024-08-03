import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_app_bar.dart';
import 'saved_items.dart';
import 'search_bar.dart';
import 'bottom_navbar.dart';
import 'shared_url_handler.dart';

class SavesScreen extends StatefulWidget {
  final FirebaseFirestore firestore;

  const SavesScreen({Key? key, required this.firestore}) : super(key: key);

  @override
  _SavesScreenState createState() => _SavesScreenState();
}

class _SavesScreenState extends State<SavesScreen> {
  String _searchQuery = '';
  late Stream<QuerySnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    _userStream = widget.firestore.collection('user1').snapshots();
    _userStream.listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>?;
          if (data != null && data['status'] == 'completed') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('New card ready: ${data['title'] ?? 'Untitled'}')),
            );
          }
        }
      }
    });

    // Set up shared URL handling
    // SharedUrlHandler.listenForSharedUrls(context);
  }

  // @override
  // void dispose() {
  //   SharedUrlHandler.dispose();
  //   super.dispose();
  // }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          SearchBarCustom(onSearch: _updateSearchQuery),
          Expanded(
            child: SavedItemsList(
              firestore: widget.firestore,
              searchQuery: _searchQuery,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(firestore: widget.firestore),
    );
  }
}
