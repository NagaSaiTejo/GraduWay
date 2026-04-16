import 'package:alumini_screen/src/alumni/chat/mentor_inbox_page.dart';
import 'package:alumini_screen/src/alumni/dashboard/student_dashboard.dart';
import 'package:alumini_screen/src/alumni/notifications/notifications_page.dart';
import 'package:alumini_screen/src/alumni/profile/profile_page.dart';
import 'package:alumini_screen/src/alumni/profile/profile_setup_page.dart';
import 'package:alumini_screen/src/alumni/shared/core/theme/app_theme.dart';
import 'package:alumini_screen/src/alumni/shared/core/widgets/floating_navbar.dart';
import 'package:alumini_screen/src/alumni/shared/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class StudentMainLayout extends StatefulWidget {
  const StudentMainLayout({super.key});

  @override
  State<StudentMainLayout> createState() => _StudentMainLayoutState();
}

class _StudentMainLayoutState extends State<StudentMainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const StudentDashboard(),
    const MentorInboxPage(),
    const NotificationsPage(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Guard: If profile is incomplete, force setup (matches mentor flow)
        if (auth.status == UserStatus.incomplete) {
          return const ProfileSetupPage();
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          extendBody: true,
          body: Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ), // Removed .animate() chain which was causing blank screen on init
              
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingNavbar(
                  selectedIndex: _selectedIndex,
                  onTap: _onItemTapped,
                ),
              ).animate().slideY(begin: 1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),
            ],
          ),
        );
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  
  const PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.textLight.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title, 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textLight
            )
          ),
          const SizedBox(height: 8),
          const Text("Coming soon for the premium student experience", 
            style: TextStyle(color: AppColors.textLight)
          ),
        ],
      ),
    );
  }
}
