import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remembo/screens/resource_screen/resource_app_bar.dart';
import 'progress_timeline.dart';
import 'package:remembo/screens/saves_screen/bottom_navbar.dart';
import 'comprehensive_quiz_screen.dart'; // Add this import

class ResourceScreen extends StatefulWidget {
  final String docId;

  const ResourceScreen({Key? key, required this.docId}) : super(key: key);

  @override
  _ResourceScreenState createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  Map<String, dynamic>? data = {};
  int currentSectionIdentifier = 1;
  int totalSections = 0;
  int? quizScore;
  int totalQuestions = 0;
  String title = "";
  String resourceURL = "";

  @override
  void initState() {
    super.initState();
    fetchResourceData();
  }

  void fetchResourceData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user1')
        .doc(widget.docId)
        .get();
    if (snapshot.exists) {
      data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        if (mounted) {
          // Check if the widget is still mounted
          setState(() {
            title = data?['title'] ?? 'No Title';
            resourceURL = data?['url'] ?? '';
            currentSectionIdentifier = data?['currentSectionIdentifier'] ?? 1;
            quizScore = data?['quizScore'];
          });
        }
      } else {
        await FirebaseFirestore.instance
            .collection('user1')
            .doc(widget.docId)
            .set({
          'title': 'No Title',
          'url': '',
          'currentSectionIdentifier': 1,
          'quizScore': null // Explicitly set quizScore to null
        }, SetOptions(merge: true));
        if (mounted) {
          // Check if the widget is still mounted
          setState(() {
            currentSectionIdentifier = 1;
            quizScore = null;
            title = 'No Title';
            resourceURL = '';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResourceAppBar(data: data),
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

          totalSections = uniqueSectionTitles.length;
          totalQuestions =
              (data['quiz_cards']?['args']?['quiz_cards'] as List?)?.length ??
                  0;
          return SingleChildScrollView(
            child: Column(
              children: [
                ProgressTimeline(
                  sectionTitles: uniqueSectionTitles,
                  currentSectionIdentifier: currentSectionIdentifier,
                  docId: widget.docId,
                ),
                SizedBox(height: 16),
                if (currentSectionIdentifier > totalSections)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComprehensiveQuizScreen(
                            docId: widget.docId,
                            totalQuestions: totalQuestions,
                            onQuizComplete: (score) {
                              setState(() {
                                quizScore = score;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                    child: Text('Take Comprehensive Quiz'),
                  ),
                if (quizScore != null)
                  Text('Quiz Score: $quizScore/$totalQuestions'),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(firestore: FirebaseFirestore.instance),
    );
  }
}
