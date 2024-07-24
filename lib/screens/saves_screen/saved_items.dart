import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedItemsList extends StatelessWidget {
  final FirebaseFirestore firestore;

  SavedItemsList({required this.firestore});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestore.collection('user1').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: snapshot.data!.docs.map((doc) {
            Map data = doc.data() as Map;
            return SavedItem(
              title: data['title'] ?? 'No Title',
              subtitle: data['subtitle'] ?? 'No Subtitle',
              tags: List.from(data['tags'] ?? []),
              duration: data['duration'] ?? '< 5min',
              initialActiveState: data['isActive'] ?? true,
              onToggle: (bool newState) {
                // Update the document in Firestore
                doc.reference.update({'isActive': newState});
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class SavedItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final List tags;
  final String duration;
  final bool initialActiveState;
  final Function(bool) onToggle;

  SavedItem({
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.duration,
    this.initialActiveState = true,
    required this.onToggle,
  });

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
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6C56F2).withOpacity(0.1),
            blurRadius: 30,
            offset: Offset(0, 4),
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
                  style: TextStyle(fontSize: 16, color: Color(0xFF1F1F1F)),
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                  widget.onToggle(value);
                },
                activeColor: Color(0xFF6C56F2),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: TextStyle(fontSize: 14, color: Color(0xFF545454)),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              ...widget.tags.map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFF1EFFE),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        tag,
                        style:
                            TextStyle(color: Color(0xFF6C56F2), fontSize: 12),
                      ),
                    ),
                  )),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFF1EFFE),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  widget.duration,
                  style: TextStyle(color: Color(0xFF6C56F2), fontSize: 12),
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                color: Color(0xFF6C56F2),
                onPressed: () {
                  // TODO: Implement add to collections functionality
                },
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFE3E0F2)),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.more_horiz, color: Color(0xFF545454)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
