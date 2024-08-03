import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:validators/validators.dart' as validator;

class AddUrlDialog extends StatelessWidget {
  final Function(String) onSave;
  final FirebaseFirestore firestore;

  const AddUrlDialog(
      {super.key, required this.onSave, required this.firestore});

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
            if (url.isNotEmpty && validator.isURL(url)) {
              // Encode the URL
              final encodedUrl = Uri.encodeComponent(url);
              final endpoint =
                  'https://process-url-2sel6rjo4q-uc.a.run.app/?url=$encodedUrl';
              print('Endpoint: $endpoint');

              try {
                final response = await http.get(Uri.parse(endpoint));
                if (response.statusCode == 200) {
                  print(
                      'Submitted URL: $url'); // Debugging line to print the submitted URL
                  onSave(url);
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Processing $url. This may take a few minutes.')),
                  );
                } else {
                  throw Exception('Failed to process URL');
                }
              } catch (e) {
                print('Error triggering cloud function: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Error processing URL. Please try again.')),
                );
              }
            } else {
              // Handle invalid URL
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
