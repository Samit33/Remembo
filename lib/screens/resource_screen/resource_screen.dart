import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'resource_card.dart';
import 'progress_timeline.dart';
import 'package:myapp/screens/saves_screen/bottom_navbar.dart'; // Add this import

class ResourceScreen extends StatefulWidget {
  final String docId;

  const ResourceScreen({Key? key, required this.docId}) : super(key: key);

  @override
  _ResourceScreenState createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  int currentSectionIdentifier = 1; // Default value

  @override
  void initState() {
    super.initState();
    fetchCurrentSectionIdentifier();
  }

  void fetchCurrentSectionIdentifier() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user1')
        .doc(widget.docId)
        .get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>?;
      if (data != null && data['currentSectionIdentifier'] != null) {
        setState(() {
          currentSectionIdentifier = data['currentSectionIdentifier'];
        });
      } else {
        // Create currentSectionIdentifier with value of 1
        await FirebaseFirestore.instance
            .collection('user1')
            .doc(widget.docId)
            .set({'currentSectionIdentifier': 1}, SetOptions(merge: true));
        setState(() {
          currentSectionIdentifier = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resource Screen')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user1')
            .doc(widget.docId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No data available'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String title = data['title'] ?? 'No Title';
          String imageUrl = data['imageUrl'] ?? '';
          List<String> tags =
              (data['tags'] as List?)?.map((tag) => tag as String).toList() ??
                  [];

          List<Map<String, dynamic>> cards =
              (data['learning_cards']?['args']?['cards'] as List?)
                      ?.map((card) => card as Map<String, dynamic>)
                      .toList() ??
                  [];

          cards.sort((a, b) => (a['section_identifier'] as num)
              .compareTo(b['section_identifier'] as num));

          List<String> uniqueSectionTitles = [];
          Set<String> seenTitles = {};

          for (var card in cards) {
            String sectionTitle = card['section_title'] as String;
            if (!seenTitles.contains(sectionTitle)) {
              uniqueSectionTitles.add(sectionTitle);
              seenTitles.add(sectionTitle);
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ResourceCard(
                  title: title,
                  imageUrl: imageUrl,
                  tags: tags,
                ),
                ProgressTimeline(
                  sectionTitles: uniqueSectionTitles,
                  currentSectionIdentifier: currentSectionIdentifier,
                  docId: widget.docId,
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar:
          BottomNavBar(firestore: FirebaseFirestore.instance), // Add this line
    );
  }
}
