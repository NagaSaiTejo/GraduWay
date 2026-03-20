import 'package:flutter/material.dart';
import 'package:alumini_screen/src/pages/features/Common/detail_page.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/mentorship_bio_card.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/profile_quick_actions.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/profile_dashboard_grid.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/active_mentees_section.dart';

import 'package:provider/provider.dart';
import 'package:alumini_screen/src/providers/auth_provider.dart';

/// A comprehensive profile and management screen for the mentor.
/// 
/// This screen allows mentors to view their professional details, 
/// manage their mentoring philosophy, access specialized management pages 
/// (Expertise, Inquiries, etc.), and monitor active mentees.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompactHeader(context),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => Text(
                        "${auth.userName}'s Dashboard",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const MentorshipBioCard(),
                    const SizedBox(height: 24),
                    const ProfileQuickActions(),
                    const SizedBox(height: 24),
                    const ProfileDashboardGrid(),
                    const SizedBox(height: 24),
                    const ActiveMenteesSection(),
                    const SizedBox(height: 100), // Space for floating navbar
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top header with a gradient background and user summary.
  Widget _buildCompactHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topPadding + 20, left: 24, right: 24, bottom: 70),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA294F9), Color(0xFF7B66FF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildHeaderAction(context, Icons.edit_outlined, "Edit Profile"),
                  const SizedBox(width: 12),
                  _buildHeaderAction(context, Icons.notifications_outlined, "Notifications"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 64),
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 35),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${auth.techField} • Senior Mentor",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.verified_user_outlined, color: Colors.white.withOpacity(0.7), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            "${auth.company} • ${auth.yoe} YOE",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper to build small action icons in the header.
  Widget _buildHeaderAction(BuildContext context, IconData icon, String title) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(title: title, icon: icon, themeColor: const Color(0xFF7B66FF)))),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

