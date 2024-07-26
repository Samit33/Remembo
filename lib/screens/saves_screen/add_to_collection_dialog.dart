import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddToCollectionDialog extends StatefulWidget {
  final FirebaseFirestore firestore;
  final String userId;
  final String itemId;

  const AddToCollectionDialog({
    Key? key,
    required this.firestore,
    required this.userId,
    required this.itemId,
  }) : super(key: key);

  @override
  _AddToCollectionDialogState createState() => _AddToCollectionDialogState();
}

class _AddToCollectionDialogState extends State<AddToCollectionDialog> {
  String _selectedCollection = '';
  String _newCollectionName = '';
  late Future<Map<String, dynamic>> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _collectionsFuture = _fetchCollections();
  }

  Future<Map<String, dynamic>> _fetchCollections() async {
    final doc = await widget.firestore
        .collection(widget.userId)
        .doc('collections')
        .get();
    return doc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to Collection'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _collectionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final collections = snapshot.data!.keys.toList();
              return DropdownButton<String>(
                isExpanded: true,
                value: _selectedCollection.isEmpty ? null : _selectedCollection,
                hint: const Text('Select a collection'),
                items: collections.map((collection) {
                  return DropdownMenuItem<String>(
                    value: collection,
                    child: Text(collection),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCollection = value!;
                  });
                },
              );
            },
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Create New Collection',
            ),
            onChanged: (value) {
              setState(() {
                _newCollectionName = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_newCollectionName.isNotEmpty) {
              _addToCollection(_newCollectionName);
            } else if (_selectedCollection.isNotEmpty) {
              _addToCollection(_selectedCollection);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _addToCollection(String collectionName) async {
    final docRef =
        widget.firestore.collection(widget.userId).doc('collections');
    final doc = await docRef.get();
    final data = doc.data() ?? {};

    final List<String> items = List<String>.from(data[collectionName] ?? []);
    if (!items.contains(widget.itemId)) {
      items.add(widget.itemId);
    }

    await docRef.set({collectionName: items}, SetOptions(merge: true));
    Navigator.of(context).pop();
  }
}
