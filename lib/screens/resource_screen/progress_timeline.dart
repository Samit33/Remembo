import 'package:flutter/material.dart';
import '../learning_screen/learning_card.dart';

class ProgressTimeline extends StatelessWidget {
  final List<String> sectionTitles;
  final String docId;

  const ProgressTimeline({Key? key, required this.sectionTitles, required this.docId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: sectionTitles.length,
      itemBuilder: (context, index) {
        bool isCompleted = index == 0;
        bool isCurrent = index == 1;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LearningCard(
                  docId: docId,
                  sectionTitle: sectionTitles[index],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? Colors.green[800]
                        : Colors.grey[300],
                  ),
                  child: isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCurrent ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            sectionTitles[index],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontWeight:
                                  isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isCurrent)
                          Icon(Icons.refresh, color: Colors.green[800]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}