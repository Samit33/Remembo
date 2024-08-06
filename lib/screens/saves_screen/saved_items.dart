import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/design/animated_button';
import 'package:myapp/design/ui_colors.dart';
import 'package:myapp/design/ui_icons.dart';
import 'package:myapp/design/ui_values.dart';
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

class _SavedItemsListState extends State<SavedItemsList> {
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
        final processingDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return data?['status'] == 'processing';
        }).toList();
        final completedDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return data?['status'] == 'completed' || data?['status'] == null;
        }).toList();

        final filteredDocs = completedDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          if (data == null) return false;

          final title = (data['title'] as String? ?? '').toLowerCase();
          final tags = (data['overallTags'] as List<dynamic>? ?? [])
              .map((tag) => (tag as String).toLowerCase())
              .toList();
          final query = widget.searchQuery.toLowerCase();

          return title.contains(query) ||
              tags.any((tag) => tag.contains(query));
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (processingDocs.isNotEmpty)
              _buildProcessingCards(processingDocs),
            ...filteredDocs.map((doc) => _buildCompletedCard(doc)),
          ],
        );
      },
    );
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
        ...processingDocs.map((doc) => _buildProcessingCard(doc)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProcessingCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Processing $url',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(QueryDocumentSnapshot doc) {
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
      ),
    );
  }

  List<String> _getShortestTags(List<String> tags, int count) {
    if (tags.length <= count) return tags;

    tags.sort((a, b) => a.length.compareTo(b.length));
    return tags.take(count).toList();
  }
}

class SavedItem extends StatelessWidget {
  final String title;
  final List tags;
  final int currentSectionIdentifier;
  final int totalSections;
  final String itemId;

  const SavedItem({
    super.key,
    required this.title,
    required this.tags,
    required this.currentSectionIdentifier,
    required this.totalSections,
    required this.itemId,
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
              RadialProgressWidget(
                progress: currentSectionIdentifier / totalSections,
              ),
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

class RadialProgressWidget extends StatelessWidget {
  final double progress;

  const RadialProgressWidget({Key? key, required this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor:
                AlwaysStoppedAnimation<Color>(UIColors.primaryGradientColor1),
            strokeWidth: 4,
          ),
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: UIColors.primaryGradientColor1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
