import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_to_collection_dialog.dart';

class SavedItemsList extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String searchQuery;

  const SavedItemsList({
    Key? key,
    required this.firestore,
    required this.searchQuery,
  }) : super(key: key);

  @override
  _SavedItemsListState createState() => _SavedItemsListState();
}

class _SavedItemsListState extends State<SavedItemsList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.firestore.collection('user1').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredDocs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map;
          final title = (data['title'] ?? '').toLowerCase();
          final tags = List.from(data['overallTags'] ?? [])
              .map((tag) => tag.toLowerCase())
              .toList();
          final query = widget.searchQuery.toLowerCase();

          return title.contains(query) ||
              tags.any((tag) => tag.contains(query));
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: filteredDocs.map((doc) {
            if (doc.id != 'collections') {
              Map data = doc.data() as Map;
              List allTags = List.from(data['overallTags'] ?? []);
              List displayTags = _getShortestTags(allTags, 3);

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/resource_screen',
                      arguments: doc.id);
                },
                child: SavedItem(
                  itemId: doc.id,
                  title: data['title'] ?? 'No Title',
                  tags: displayTags,
                  initialActiveState: data['isActive'] ?? true,
                  onToggle: (bool newState) {
                    doc.reference.update({'isActive': newState});
                  },
                ),
              );
            } else {
              return Container(); // Return an empty container for 'collections' document
            }
          }).toList(),
        );
      },
    );
  }

  List _getShortestTags(List tags, int count) {
    if (tags.length <= count) return tags;

    tags.sort((a, b) => a.length.compareTo(b.length));
    return tags.take(count).toList();
  }
}

class SavedItem extends StatefulWidget {
  final String title;
  final List tags;
  final bool initialActiveState;
  final Function(bool) onToggle;
  final String itemId;

  const SavedItem({
    Key? key,
    required this.title,
    required this.tags,
    required this.initialActiveState,
    required this.onToggle,
    required this.itemId,
  }) : super(key: key);

  @override
  _SavedItemState createState() => _SavedItemState();
}

class _SavedItemState extends State<SavedItem> {
  late bool isActive;

  @override
  void initState() {
    super.initState();
    isActive = widget.initialActiveState;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
              ),
              CupertinoSwitch(
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                  widget.onToggle(value);
                },
                activeColor: const Color(0xFF6C56F2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  children:
                      widget.tags.take(3).map((tag) => _buildTag(tag)).toList(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF6C56F2),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddToCollectionDialog(
                      firestore: FirebaseFirestore.instance,
                      userId: 'user1', // Replace with your actual user ID
                      itemId: widget.itemId, // Replace with your actual item ID
                    ),
                  ); // TODO: Implement add to collections functionality
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFFE),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Color(0xFF6C56F2),
          fontSize: 12,
        ),
      ),
    );
  }
}
