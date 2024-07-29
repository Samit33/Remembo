import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUrlDialog extends StatelessWidget {
  final Function(String) onSave;
  final FirebaseFirestore firestore;

  const AddUrlDialog({super.key, required this.onSave, required this.firestore});

  @override
  Widget build(BuildContext context) {
    String url = '';

    return AlertDialog(
      title: const Text('Add a URL'),
      content: TextField(
        decoration: InputDecoration(
          hintText: 'e.g. https://fs.blog/first-principles/',
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          url = value;
        },
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          onPressed: () async {
            if (await canLaunchUrl(Uri.parse(url))) {
              // Add the URL to Firestore with 'processing' status
              await firestore.collection('user1').add({
                'url': url,
                'status': 'processing',
                'timestamp': FieldValue.serverTimestamp(),
              });

              // Trigger the cloud function
              final endpoint =
                  'https://process-url-2sel6rjo4q-uc.a.run.app/?url=$url';
              final response = await http.get(Uri.parse(endpoint));
              if (response.statusCode == 200) {
                onSave(url);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Processing $url. This may take a few minutes.')),
                );
              } else {
                // Handle error
                print(
                    'Error triggering cloud function: ${response.statusCode}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Error processing URL. Please try again.')),
                );
              }
            } else {
              // Handle invalid URL
              print('Invalid URL');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Invalid URL. Please enter a valid URL.')),
              );
            }
          },
          child: const Text('Save to Rememdo',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
