import 'package:flutter/material.dart';
import 'package:remembo/design/animated_button';
import 'package:remembo/design/ui_colors.dart';
import 'package:remembo/design/ui_icons.dart';
import 'package:remembo/design/ui_values.dart';

class SearchBarCustom extends StatelessWidget {
  final Function(String) onSearch;

  const SearchBarCustom({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(UiValues.defaultBorderRadius),
          boxShadow: const [UIColors.dropShadow],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Image.asset(UiAssets.searchIcon),
            ),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: onSearch,
              ),
            ),
            AnimatedButton(
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: UIColors.secondaryColor,
                    borderRadius:
                        BorderRadius.circular(UiValues.defaultBorderRadius),
                  ),
                  child: Image.asset(
                    UiAssets.filterIcon,
                    color: Colors.white,
                  )),
              onTap: () {
                // Add your custom logic here
              },
            ),
          ],
        ),
      ),
    );
  }
}
