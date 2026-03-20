import 'package:flutter/material.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/professional_page.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/skills_page.dart';
import 'package:alumini_screen/src/pages/features/profile_pages/contact_page.dart';
import 'package:alumini_screen/src/pages/features/Mentorship/alumni_requests_page.dart';
import 'package:alumini_screen/src/pages/features/Common/detail_page.dart';

class ProfileDashboardGrid extends StatelessWidget {
  const ProfileDashboardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildDashboardCard(
          context,
          "Background",
          "Career & History",
          Icons.workspace_premium_outlined,
          const Color(0xFF64B5F6),
          const ProfessionalPage(),
        ),
        _buildDashboardCard(
          context,
          "Expertise",
          "Mentoring Topics",
          Icons.psychology_outlined,
          const Color(0xFF81C784),
          const SkillsPage(),
        ),
        _buildDashboardCard(
          context,
          "Inquiries",
          "Student Queries",
          Icons.pending_actions_outlined,
          const Color(0xFFFFB74D),
          const AlumniRequestsPage(),
        ),
        _buildDashboardCard(
          context,
          "Webinars",
          "Host Live Sessions",
          Icons.video_camera_front_outlined,
          const Color(0xFFBA68C8),
          const PlaceholderScreen(title: "Sessions", icon: Icons.video_camera_front_outlined),
        ),
        _buildDashboardCard(
          context,
          "Badges",
          "Mentor Recognition",
          Icons.emoji_events_outlined,
          const Color(0xFFFFD54F),
          const DetailPage(title: "Mentor Awards", icon: Icons.emoji_events_outlined, themeColor: Color(0xFFFFD54F)),
        ),
        _buildDashboardCard(
          context,
          "Office Hours",
          "Availability",
          Icons.alternate_email_outlined,
          const Color(0xFFF06292),
          const ContactPage(),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget targetPage) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage)),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Icon(icon, size: 100, color: Colors.grey)),
    );
  }
}
