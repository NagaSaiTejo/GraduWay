import 'package:flutter/material.dart';

class MentorshipBioCard extends StatelessWidget {
  const MentorshipBioCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                "Mentoring Philosophy",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "I believe in building a strong foundation in core engineering principles. Happy to guide students on System Design, Flutter Architecture, and Career Growth.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
