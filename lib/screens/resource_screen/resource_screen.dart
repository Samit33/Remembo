import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'resource_card.dart';
import 'progress_timeline.dart';
import '../learning_screen/learning_card.dart';
import '../learning_screen/quiz_card.dart';

class ResourceScreen extends StatefulWidget {
  final String docId;

  const ResourceScreen({Key? key, required this.docId}) : super(key: key);

  @override
  _ResourceScreenState createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  int currentSectionIndex = 0;
  bool allSectionsCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }

  void _loadUserProgress() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user1')
        .doc(widget.docId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        currentSectionIndex = data['currentSectionIndex'] ?? 0;
        allSectionsCompleted = data['allSectionsCompleted'] ?? false;
      });
    }
  }

  void _updateUserProgress() async {
    await FirebaseFirestore.instance
        .collection('user1')
        .doc(widget.docId)
        .update({
      'currentSectionIndex': currentSectionIndex,
      'allSectionsCompleted': allSectionsCompleted,
    });
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
          String description = data['description'] ?? 'No Description';
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
                  description: description,
                  imageUrl: imageUrl,
                  tags: tags,
                ),
                ProgressTimeline(
                  sectionTitles: uniqueSectionTitles,
                  currentSectionIndex: currentSectionIndex,
                  docId: widget.docId,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            if (allSectionsCompleted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizCard(
                    docId: widget.docId,
                    sectionTitle: 'All Sections',
                    onQuizComplete: () {
                      // Handle final quiz completion
                    },
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LearningCard(
                    docId: widget.docId,
                    sectionTitle: '',
                    onSectionComplete: () {
                      setState(() {
                        currentSectionIndex++;
                        if (currentSectionIndex == 3) {
                          // Assuming 3 sections
                          allSectionsCompleted = true;
                        }
                        _updateUserProgress();
                      });
                    },
                  ),
                ),
              );
            }
          },
          child: Text(allSectionsCompleted ? 'Take Final Quiz' : 'Start'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),
      ),
    );
  }
}