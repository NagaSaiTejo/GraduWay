import 'package:flutter/material.dart';
import 'package:alumini_screen/src/pages/nav_tabs/mentor_inbox_page.dart';
import 'package:alumini_screen/src/pages/features/Mentorship/interactive_classroom_page.dart';
import 'package:alumini_screen/src/pages/features/Mentorship/broadcast_streaming_page.dart';

class ProfileQuickActions extends StatelessWidget {
  const ProfileQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            "Start Session",
            Icons.add_circle_outline,
            const Color(0xFF7B66FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            context,
            "Manage Mentees",
            Icons.people_outline,
            Colors.white,
            isOutlined: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, {bool isOutlined = false}) {
    return ElevatedButton.icon(
      onPressed: () {
        if (label == "Start Session") {
          _showStartSessionSheet(context);
        } else if (label == "Manage Mentees") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MentorInboxPage()));
        }
      },
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.white : color,
        foregroundColor: isOutlined ? const Color(0xFF7B66FF) : Colors.white,
        elevation: isOutlined ? 0 : 2,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isOutlined ? const BorderSide(color: Color(0xFF7B66FF)) : BorderSide.none,
        ),
      ),
    );
  }

  void _showStartSessionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Start New Session",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Host a webinar or a quick Q&A session.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSessionOption(
              context,
              Icons.groups_outlined, 
              "Interactive Class", 
              "Real-time video with students. (WebRTC)",
              onSelect: () => _navigateTo(context, "classroom"),
            ),
            const SizedBox(height: 12),
            _buildSessionOption(
              context,
              Icons.sensors, 
              "Go Live (Broadcast)", 
              "Stream to unlimited viewers. (RTMP)",
              onSelect: () => _navigateTo(context, "broadcast"),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B66FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Cancel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionOption(BuildContext context, IconData icon, String title, String desc, {VoidCallback? onSelect}) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String type) {
    Navigator.pop(context); // Close sheet
    if (type == "classroom") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const InteractiveClassroomPage(roomId: "Design-101")));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BroadcastStreamingPage(streamId: "mentor-live-1")));
    }
  }
}
