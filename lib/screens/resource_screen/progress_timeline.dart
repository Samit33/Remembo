import 'package:flutter/material.dart';

class ProgressTimeline extends StatelessWidget {
  final List<String> sectionTitles;

  const ProgressTimeline({Key? key, required this.sectionTitles})
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
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isCompleted || isCurrent ? Colors.blue : Colors.grey[300],
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
                      Text(
                        sectionTitles[index],
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
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
        );
      },
    );
  }
}
