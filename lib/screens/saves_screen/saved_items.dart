import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/design/animated_button';
import 'package:myapp/design/ui_colors.dart';
import 'package:myapp/design/ui_icons.dart';
import 'package:myapp/design/ui_values.dart';
import 'radial_progress.dart';
import 'add_to_collection_dialog.dart';

class SavedItemsList extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String searchQuery;

  const SavedItemsList({
    super.key,
    required this.firestore,
    required this.searchQuery,
  });

  @override
  _SavedItemsListState createState() => _SavedItemsListState();
}

class _SavedItemsListState extends State<SavedItemsList>
    with TickerProviderStateMixin {
  late AnimationController _sequentialController;
  List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    _sequentialController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Total duration for all animations
    );
  }

  @override
  void dispose() {
    _sequentialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.firestore.collection('user1').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = snapshot.data!.docs;
        final processingDocs = _getProcessingDocs(allDocs);
        final filteredDocs = _filterAndSortDocs(allDocs);

        // Create sequential animations
        _createSequentialAnimations(filteredDocs.length);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (processingDocs.isNotEmpty)
              _buildProcessingCards(processingDocs),
            ...filteredDocs.asMap().entries.map((entry) {
              final index = entry.key;
              final doc = entry.value;
              return _buildCompletedCard(doc, _animations[index]);
            }),
          ],
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _getProcessingDocs(
      List<QueryDocumentSnapshot> allDocs) {
    return allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['status'] == 'processing';
    }).toList();
  }

  List<QueryDocumentSnapshot> _filterAndSortDocs(
      List<QueryDocumentSnapshot> allDocs) {
    final completedDocs = allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['status'] == 'completed' || data?['status'] == null;
    }).toList();

    // Filter out the 'collections' document and separate processing/completed docs
    final filteredDocs = allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || doc.id == 'collections') return false;

      final status = data['status'] as String?;
      if (status == 'processing') return false;

      final title = (data['title'] as String? ?? '').toLowerCase();
      final tags = (data['overallTags'] as List<dynamic>? ?? [])
          .map((tag) => (tag as String).toLowerCase())
          .toList();
      final query = widget.searchQuery.toLowerCase();

      return title.contains(query) || tags.any((tag) => tag.contains(query));
    }).toList();

    // Sort filtered documents by timestamp in descending order
    filteredDocs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>?;
      final bData = b.data() as Map<String, dynamic>?;
      final aTimestamp = aData?['timestamp'] as Timestamp?;
      final bTimestamp = bData?['timestamp'] as Timestamp?;
      if (aTimestamp == null || bTimestamp == null) return 0;
      return bTimestamp.compareTo(aTimestamp);
    });

    return filteredDocs;
  }

  void _createSequentialAnimations(int count) {
    _animations.clear();
    final interval = 1.0 / count;
    for (int i = 0; i < count; i++) {
      final start = interval * i;
      final end = start + interval;
      _animations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _sequentialController,
            curve: Interval(start, end, curve: Curves.easeInOut),
          ),
        ),
      );
    }
    _sequentialController.forward(from: 0);
  }

  Widget _buildProcessingCards(List<QueryDocumentSnapshot> processingDocs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Processing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...processingDocs.map((doc) => ProcessingCard(doc: doc)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCompletedCard(
      QueryDocumentSnapshot doc, Animation<double> animation) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null || doc.id == 'collections') {
      return Container();
    }

    final allTags =
        (data['overallTags'] as List<dynamic>? ?? []).cast<String>();
    final displayTags = _getShortestTags(allTags, 3);

    final totalSections =
        (data['learning_cards']?['args']?['cards'] as List?)?.length ?? 1;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/resource_screen', arguments: doc.id);
      },
      child: SavedItem(
        itemId: doc.id,
        title: data['title'] as String? ?? 'No Title',
        tags: displayTags,
        currentSectionIdentifier: data['currentSectionIdentifier'] as int? ?? 1,
        totalSections: totalSections,
        progressAnimation: animation,
      ),
    );
  }

  List<String> _getShortestTags(List<String> tags, int count) {
    if (tags.length <= count) return tags;

    tags.sort((a, b) => a.length.compareTo(b.length));
    return tags.take(count).toList();
  }
}

class ProcessingCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const ProcessingCard({Key? key, required this.doc}) : super(key: key);

  @override
  _ProcessingCardState createState() => _ProcessingCardState();
}

class _ProcessingCardState extends State<ProcessingCard> {
  late Timer _timer;
  int _currentIndex = 0;
  final List<String> _processingTexts = [
    'Processing new save',
    'Your learning journey is brewing...',
    'Preparing your knowledge cards!',
    'Breaking down your saved link into simple steps...',
    'Turning your saved chaos into clear learning...',
    'Almost there!'
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentIndex < _processingTexts.length - 1) {
        setState(() {
          _currentIndex++;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>?;
    final url = data?['url'] as String? ?? 'Unknown URL';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(UIColors.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '${_processingTexts[_currentIndex]}',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class SavedItem extends StatelessWidget {
  final String itemId;
  final String title;
  final List<String> tags;
  final int currentSectionIdentifier;
  final int totalSections;
  final Animation<double> progressAnimation;

  const SavedItem({
    super.key,
    required this.itemId,
    required this.title,
    required this.tags,
    required this.currentSectionIdentifier,
    required this.totalSections,
    required this.progressAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UiValues.defaultBorderRadius),
        boxShadow: const [UIColors.dropShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: UIColors.headerColor,
                  ),
                ),
              ),
              AnimatedRadialProgressWidget(animation: progressAnimation),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  children: tags.take(3).map((tag) => _buildTag(tag)).toList(),
                ),
              ),
              AnimatedButton(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(UiValues.defaultBorderRadius),
                    boxShadow: const [UIColors.dropShadow],
                  ),
                  child: Image.asset(UiAssets.addToCollectionIcon,
                      width: 24, height: 24),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddToCollectionDialog(
                      firestore: FirebaseFirestore.instance,
                      userId: 'user1',
                      itemId: itemId,
                    ),
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: UIColors.secondaryBGColor,
        borderRadius: BorderRadius.circular(UiValues.defaultBorderRadius),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: UIColors.secondaryColor,
          fontSize: 12,
        ),
      ),
    );
  }
}
