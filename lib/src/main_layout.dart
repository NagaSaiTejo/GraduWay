import 'package:flutter/material.dart';
import 'package:alumini_screen/src/pages/dashboard_page.dart';
import 'package:alumini_screen/src/pages/profile_page.dart';
import 'package:alumini_screen/src/pages/mentor_inbox_page.dart';
import 'package:alumini_screen/src/pages/placeholder_page.dart';
import 'package:alumini_screen/src/widgets/floating_navbar.dart';

class MainLayout extends StatefulWidget {
  final String userName;
  final String techField;

  const MainLayout({
    super.key,
    required this.userName,
    required this.techField,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Dashboard(userName: widget.userName, techField: widget.techField),
      const PlaceholderScreen(title: "Alumni Directory", icon: Icons.people_alt_outlined),
      const MentorInboxPage(),
      const PlaceholderScreen(title: "Notifications", icon: Icons.notifications_none),
      ProfileScreen(userName: widget.userName, techField: widget.techField),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBody: true, // Allows content to flow behind the glass navbar
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingNavbar(
              selectedIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}

