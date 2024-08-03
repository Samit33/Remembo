import 'package:flutter/material.dart';

class ResourceCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final List<String> tags;

  const ResourceCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.green[100],
                          labelStyle: TextStyle(color: Colors.blue[800]),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
