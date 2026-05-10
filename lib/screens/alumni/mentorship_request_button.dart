import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../data/models/alumni_model.dart';

/// A smart button that shows the real-time mentorship request status
/// between the currently logged-in student and a specific alumni.
///
/// States:
///   - "Request Mentorship" → no request yet
///   - "Request Sent" (disabled) → pending
///   - "Mentoring Active" (success) → accepted
class MentorshipRequestButton extends ConsumerWidget {
  final AlumniModel alumni;
  const MentorshipRequestButton({super.key, required this.alumni});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(authProvider).student;
    if (student == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mentorship_requests')
          .where('studentId', isEqualTo: student.id)
          .where('alumniId', isEqualTo: alumni.id)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 48,
            child: Center(child: LinearProgressIndicator()),
          );
        }

        final hasRequest =
            snapshot.hasData && snapshot.data!.docs.isNotEmpty;
        final status = hasRequest
            ? snapshot.data!.docs.first.data()
                as Map<String, dynamic>
            : null;
        final requestStatus = status?['status'] as String?;

        Color buttonColor;
        IconData buttonIcon;
        String buttonLabel;
        bool isEnabled;

        switch (requestStatus) {
          case 'accepted':
            buttonColor = AppColors.success;
            buttonIcon = Icons.check_circle_rounded;
            buttonLabel = 'Mentoring Active';
            isEnabled = false;
            break;
          case 'pending':
            buttonColor = AppColors.textMuted;
            buttonIcon = Icons.hourglass_top_rounded;
            buttonLabel = 'Request Sent';
            isEnabled = false;
            break;
          default:
            buttonColor = AppColors.primary;
            buttonIcon = Icons.handshake_rounded;
            buttonLabel = 'Request Mentorship';
            isEnabled = true;
        }

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed:
                isEnabled ? () => _sendRequest(context, student.id) : null,
            icon: Icon(buttonIcon, size: 20),
            label: Text(
              buttonLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: buttonColor.withValues(alpha: 0.7),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendRequest(BuildContext context, String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('mentorship_requests')
          .add({
        'studentId': studentId,
        'alumniId': alumni.id,
        'alumniName': alumni.name,
        'alumniCompany': alumni.company,
        'alumniPhotoUrl': alumni.photoUrl,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mentorship request sent to ${alumni.name}!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
