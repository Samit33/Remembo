// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:myapp/design/UIColors.dart';
// import 'add_url_dialog.dart';

// class BottomNavBar extends StatelessWidget {
//   final FirebaseFirestore firestore;

//   const BottomNavBar({Key? key, required this.firestore}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 80,
//       decoration: const BoxDecoration(
//         color: UIColors.secondaryColor,
//         borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(20), topRight: Radius.circular(20)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildNavItem(Icons.home, isActive: true),
//           _buildNavItem(Icons.list),
//           _buildNavItem(Icons.info_outline),
//           _buildAddButton(context),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(IconData icon, {bool isActive = false}) {
//     return Icon(
//       icon,
//       color: isActive ? UIColors.iconColor : UIColors.disabledColor,
//     );
//   }

//   Widget _buildAddButton(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _showAddUrlDialog(context),
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: Colors.green,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   void _showAddUrlDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AddUrlDialog(
//           onSave: (url) {
//             // TODO: Implement save functionality
//             print('URL to save: $url');
//           },
//           firestore: firestore,
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/design/animated_button';
import 'package:myapp/design/ui_colors.dart';
import 'package:myapp/design/ui_icons.dart';
import 'add_url_dialog.dart';

class BottomNavBar extends StatefulWidget {
  final FirebaseFirestore firestore;

  const BottomNavBar({super.key, required this.firestore});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add your navigation logic here
      switch (index) {
        case 0:
          // Navigate to Home screen
          break;
        case 1:
          // Navigate to List screen
          break;
        case 2:
          // Navigate to Info screen
          break;

        case 3:
          // Trigger Add button action (e.g., show a dialog)
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddUrlDialog(
                onSave: (url) {
                  // TODO: Implement save functionality
                  print('URL to save: $url');
                },
                firestore: widget.firestore,
              );
            },
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: UIColors.secondaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0),
          _buildNavItem(1),
          _buildNavItem(2),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    return AnimatedButton(
        onTap: () => _onItemTapped(index),
        child: Image.asset(
          get_icon(index),
        ));
  }

  String get_icon(int index) {
    switch (index) {
      case 0:
        return _selectedIndex == index
            ? UiAssets.homeIconSelected
            : UiAssets.homeIconNormal;
      case 1:
        return _selectedIndex == index
            ? UiAssets.savesIconSelected
            : UiAssets.savesIconNormal;
      case 2:
        return _selectedIndex == index
            ? UiAssets.infoIconSelected
            : UiAssets.infoIconNormal;
      default:
        return UiAssets.homeIconNormal;
    }
  }

  Widget _buildAddButton(BuildContext context) {
    return AnimatedButton(
        onTap: () => _onItemTapped(3),
        child: Image.asset(UiAssets.addIcon, width: 40, height: 40)

        // Container(
        //   padding: const EdgeInsets.all(12),
        //   decoration: const BoxDecoration(
        //     shape: BoxShape.circle,
        //     color: UIColors.iconColor,
        //   ),
        //   child: const Icon(
        //     Icons.add,
        //     color: Colors.white,
        //   ),
        // ),
        );
  }
}
