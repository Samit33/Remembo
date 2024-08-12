import 'package:flutter/material.dart';
import 'package:remembo/design/ui_icons.dart';
import 'package:remembo/screens/saves_screen/category_tabs.dart';

class SavesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SavesAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170, // Adjust height as needed
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage(UiAssets.savesScreenHeaderBG),
            fit: BoxFit.fill,
            alignment: Alignment.center),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Saves',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: Image.asset(UiAssets.appIcon),
              ),
            ],
          ),
          const PreferredSize(
            preferredSize: Size.fromHeight(40.0), // Adjust height as needed
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CategoryTabs(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(170.0); // Adjust height as needed
}
