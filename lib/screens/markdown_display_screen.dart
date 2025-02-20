import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownDisplayScreen extends StatelessWidget {
  final String markdownContent;
  final String title;

  const MarkdownDisplayScreen({
    Key? key,
    required this.markdownContent,
    this.title = 'Article',
  }) : super(key: key);

  /// Splits the provided markdown content into segments.
  /// Segments wrapped in <review_cards></review_cards> are tagged as 'review'
  /// and the rest as 'markdown'.
  List<Map<String, String>> _parseContent(String content) {
    List<Map<String, String>> segments = [];
    int start = 0;
    while (true) {
      int reviewStart = content.indexOf("<review_cards>", start);
      if (reviewStart == -1) {
        // No more review cards; add remaining text as markdown.
        segments.add({'type': 'markdown', 'text': content.substring(start)});
        break;
      }
      if (reviewStart > start) {
        segments.add({
          'type': 'markdown',
          'text': content.substring(start, reviewStart)
        });
      }
      int reviewEnd = content.indexOf("</review_cards>", reviewStart);
      if (reviewEnd == -1) {
        segments
            .add({'type': 'markdown', 'text': content.substring(reviewStart)});
        break;
      }
      String reviewContent =
          content.substring(reviewStart + "<review_cards>".length, reviewEnd);
      segments.add({'type': 'review', 'text': reviewContent.trim()});
      start = reviewEnd + "</review_cards>".length;
    }
    return segments;
  }

  @override
  Widget build(BuildContext context) {
    final segments = _parseContent(markdownContent);

    // Customized markdown style similar to Pocket/Instapaper.
    final markdownStyle = MarkdownStyleSheet(
      p: const TextStyle(
          fontSize: 18,
          height: 1.6,
          fontFamily: 'Georgia',
          color: Colors.black87),
      h1: const TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
      h2: const TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
      h3: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
      h4: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
      blockSpacing: 20,
      listIndent: 32,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: segments.length,
              itemBuilder: (context, index) {
                final segment = segments[index];
                if (segment['type'] == 'markdown') {
                  return MarkdownBody(
                    data: segment['text']!,
                    styleSheet: markdownStyle,
                    onTapLink: (text, href, title) async {
                      if (href != null && await canLaunchUrl(Uri.parse(href))) {
                        await launchUrl(Uri.parse(href));
                      }
                    },
                  );
                } else if (segment['type'] == 'review') {
                  return ExpandableReviewCard(content: segment['text']!);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A card widget that is collapsed by default.
/// Tapping the card toggles a smooth animated transition revealing the full review.
class ExpandableReviewCard extends StatefulWidget {
  final String content;
  const ExpandableReviewCard({Key? key, required this.content})
      : super(key: key);

  @override
  _ExpandableReviewCardState createState() => _ExpandableReviewCardState();
}

class _ExpandableReviewCardState extends State<ExpandableReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        firstChild: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Show Review Card",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        secondChild: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Review Card",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Icon(Icons.keyboard_arrow_up),
                  ],
                ),
                const SizedBox(height: 8),
                Text(widget.content, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
        crossFadeState:
            _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      ),
    );
  }
}
