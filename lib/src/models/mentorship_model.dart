enum MentorshipStatus { pending, accepted, rejected, ended }

class MentorshipRequest {
  final String id;
  final String studentName;
  final String studentBranch;
  final String studentYear;
  final List<String> studentSkills;
  final String reason;
  final List<String> topics;
  final String? preferredSchedule;
  final MentorshipStatus status;
  final DateTime createdAt;

  MentorshipRequest({
    required this.id,
    required this.studentName,
    required this.studentBranch,
    required this.studentYear,
    required this.studentSkills,
    required this.reason,
    required this.topics,
    this.preferredSchedule,
    this.status = MentorshipStatus.pending,
    required this.createdAt,
  });

  MentorshipRequest copyWith({
    MentorshipStatus? status,
  }) {
    return MentorshipRequest(
      id: id,
      studentName: studentName,
      studentBranch: studentBranch,
      studentYear: studentYear,
      studentSkills: studentSkills,
      reason: reason,
      topics: topics,
      preferredSchedule: preferredSchedule,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
