import 'package:flutter/material.dart';
import 'package:myapp/design/animated_button';
import 'package:myapp/design/ui_colors.dart';
import 'package:myapp/design/ui_icons.dart';
import 'package:myapp/design/ui_values.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceAppBar extends StatelessWidget implements PreferredSizeWidget {
  String title = "";
  String url = "";
  String imageURL = "";
  ImageProvider<Object> imageProvider =
      const AssetImage(UiAssets.resourceScreenHeaderBGDefault);
  final Map<String, dynamic>? data;

  ResourceAppBar({super.key, required this.data}) {
    title = data?['title'] ?? "";
    url = data?['url'] ?? "";
    imageURL = data?['imageUrl'] ?? "";
    imageProvider = CachedNetworkImageProvider(imageURL);
  }
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.zero,
              bottomLeft: Radius.circular(UiValues.defaultBorderRadius * 2),
              bottomRight: Radius.circular(UiValues.defaultBorderRadius * 2),
            ),
            child: Container(
              height: 250, // Adjust height as needed
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.zero,
                  topRight: Radius.zero,
                  bottomLeft: Radius.circular(UiValues.defaultBorderRadius * 2),
                  bottomRight:
                      Radius.circular(UiValues.defaultBorderRadius * 2),
                ),
                image: DecorationImage(
                  image: imageURL != ""
                      ? imageProvider
                      : const AssetImage(
                          UiAssets.resourceScreenHeaderBGDefault),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) => const DecorationImage(
                    //This is not working for some reason, leaving it here for reference
                    image: AssetImage(UiAssets.resourceScreenHeaderBGDefault),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Stack(children: [
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedButton(
                              child: Container(
                                  width: 200,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: UIColors.secondaryBGColor
                                        .withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(
                                        UiValues.defaultBorderRadius),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.link,
                                        color: UIColors.secondaryBGColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          url,
                                          style: const TextStyle(
                                            color: UIColors.secondaryBGColor,
                                            fontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              onTap: () {
                                // Open URL in browser
                                launchUrl(Uri.parse(url),
                                    mode: LaunchMode.externalApplication);
                              },
                            ),
                          ],
                        ),
                      )
                    ]),
                  ),
                ],
              ),
            )));
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(250.0); // Adjust height as needed
}
