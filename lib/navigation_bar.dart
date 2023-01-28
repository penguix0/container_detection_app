import 'package:container_detection_app/Image/image.dart';
import 'package:container_detection_app/Results/results.dart';
import 'package:container_detection_app/main.dart';
import 'package:container_detection_app/Recognition/recognition.dart';
import 'package:flutter/material.dart';

class MenuNavigationBar extends StatefulWidget {
  const MenuNavigationBar({
    Key? key,
  }) : super(key: key);

  @override
  State<MenuNavigationBar> createState() => _MenuNavigationBarState();
}

class _MenuNavigationBarState extends State<MenuNavigationBar> {
  void onItemTapped(int index) {
    if (tabIndex == index) {
      return;
    }

    setState(() {
      tabIndex = index;
    });
    StatefulWidget route;
    if (index == 0) {
      route = const Images();
    } else if (index == 1) {
      route = const Recognition();
    } else if (index == 2) {
      route = const Results();
    } else {
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => route,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: tabIndex,
      onDestinationSelected: (int index) {
        setState(() {
          onItemTapped(index);
        });
      },
      destinations: const [
        NavigationDestination(
          selectedIcon: Icon(Icons.photo_library),
          icon: Icon(Icons.photo_library),
          label: 'Image',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.view_in_ar),
          icon: Icon(Icons.view_in_ar),
          label: 'Recognition',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.image_search),
          icon: Icon(Icons.image_search),
          label: 'Results',
        ),
      ],
    );
  }
}
