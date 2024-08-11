import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'saves_app_bar.dart';
import 'saved_items.dart';
import 'search_bar.dart';
import 'bottom_navbar.dart';

class SavesScreen extends StatefulWidget {
  final FirebaseFirestore firestore;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  const SavesScreen(
      {Key? key, required this.firestore, required this.notificationsPlugin})
      : super(key: key);

  @override
  _SavesScreenState createState() => _SavesScreenState();
}

class _SavesScreenState extends State<SavesScreen> {
  String _searchQuery = '';
  late Stream<QuerySnapshot> _userStream;
  String? _previousStatus;

  @override
  void initState() {
    super.initState();
    _userStream = widget.firestore.collection('user1').snapshots();
    _userStream.listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>?;
          if (data != null) {
            final status = data['status'] as String?;
            if (status == 'completed' && _previousStatus == 'processing') {
              _showNotification(data['title'] ?? 'Untitled', change.doc.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('New card ready: ${data['title'] ?? 'Untitled'}'),
                ),
              );
            }
            _previousStatus = status;
          }
        }
      }
    });
  }

  Future<void> _showNotification(String title, String docId) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await widget.notificationsPlugin.show(
      0,
      'Resume learning next section',
      'What are Large Language Models(LLMs)?',
      platformChannelSpecifics,
      payload: docId, // Pass the document ID as the payload
    );
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SavesAppBar(),
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
