import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AddUrlDialog extends StatelessWidget {
  final Function(String) onSave;

  const AddUrlDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String url = '';

    return AlertDialog(
      title: const Text('Add a URL'),
      content: TextField(
        decoration: InputDecoration(
          hintText: 'e.g. https://fs.blog/first-principles/',
          hintStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey[400]), // Smaller, lighter hintText
          border: OutlineInputBorder(),
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
              // URL is valid, trigger Firestore cloud function
              final endpoint = 'https://process-url-2sel6rjo4q-uc.a.run.app/?url=$url';
              final response = await http.get(Uri.parse(endpoint));
              if (response.statusCode == 200) {
                onSave(url);
                Navigator.of(context).pop();
              } else {
                // Handle error
                print('Error triggering cloud function: ${response.statusCode}');
              }
            } else {
              // Handle invalid URL
              print('Invalid URL');
            }
          },
          child: const Text('Save to Rememdo',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
