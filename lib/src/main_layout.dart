import 'package:flutter/material.dart';
import 'package:alumini_screen/src/dashboard.dart';
import 'package:alumini_screen/src/profile.dart';
import 'package:alumini_screen/src/pages/mentor_inbox_page.dart';
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

// Simple placeholder for the unbuilt screens
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Nothing",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
