import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saves Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Campton',
      ),
      home: SavesScreen(),
    );
  }
}

class SavesScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9C91FC), Color(0xFF6952F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saves',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFFBFB7F4),
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            NetworkImage('https://example.com/placeholder.jpg'),
                      ),
                    ),
                  ],
                ),
              ),
              CategoryTabs(),
              SearchBar(),
              Expanded(
                child: SavedItemsList(firestore: firestore),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

// You'll need to update the SavedItemsList to use the new SavedItem widget
class SavedItemsList extends StatelessWidget {
  final FirebaseFirestore firestore;

  SavedItemsList({required this.firestore});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return SavedItem(
              title: data['title'] ?? 'No Title',
              subtitle: data['subtitle'] ?? 'No Subtitle',
              tags: List<String>.from(data['tags'] ?? []),
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

class CategoryTab extends StatelessWidget {
  final String title;
  final bool isSelected;

  CategoryTab(this.title, {this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: isSelected ? Colors.white : Color(0xFFB9AFFF),
        fontSize: 16,
      ),
    );
  }
}

class CategoryTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CategoryTab('All', isSelected: true),
          CategoryTab('Active'),
          CategoryTab('Collections'),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.symmetric(horizontal: 14),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Color(0xFF545454)),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF545454), fontSize: 16),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C91FC), Color(0xFF6952F0)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.tune, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

class SavedItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> tags;
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

class BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C91FC), Color(0xFF6952F0)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavBarIcon(Icons.home_outlined),
          NavBarIcon(Icons.bookmark_border),
          NavBarIcon(Icons.access_time),
          Container(
            width: 52,
            height: 26,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9C91FC), Color(0xFF6952F0)],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Center(
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarIcon extends StatelessWidget {
  final IconData icon;

  NavBarIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Colors.white);
  }
}
