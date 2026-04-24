// ─── Post (Alumni insights/tips) ─────────────────────────────────────────────
class PostModel {
  final String id;
  final String alumniId;
  final String alumniName;
  final String alumniCompany;
  final String alumniPhotoUrl;
  final String content;
  final String type; // 'advice', 'story', 'confession', 'tip'
  final List<String> tags;
  final int likes;
  final int saves;
  final bool isAnonymous;
  final DateTime postedAt;

  const PostModel({
    required this.id,
    required this.alumniId,
    required this.alumniName,
    required this.alumniCompany,
    required this.alumniPhotoUrl,
    required this.content,
    required this.type,
    required this.tags,
    required this.likes,
    required this.saves,
    required this.isAnonymous,
    required this.postedAt,
  });
}

// ─── Q&A Question ─────────────────────────────────────────────────────────────
class QAModel {
  final String id;
  final String question;
  final String askedBy;      // student name
  final String askedById;    // student id
  final DateTime timestamp;
  final int upvotes;
  final List<String> tags;
  final List<QAAnswer> answers;
  final bool isAnswered;

  const QAModel({
    required this.id,
    required this.question,
    required this.askedBy,
    required this.askedById,
    required this.timestamp,
    required this.upvotes,
    required this.tags,
    required this.answers,
    required this.isAnswered,
  });
}

// ─── Q&A Answer ───────────────────────────────────────────────────────────────
class QAAnswer {
  final String id;
  final String alumniId;
  final String alumniName;
  final String alumniCompany;
  final String alumniPhotoUrl;
  final String answer;
  final bool isBestAnswer;
  final int upvotes;
  final DateTime answeredAt;

  const QAAnswer({
    required this.id,
    required this.alumniId,
    required this.alumniName,
    required this.alumniCompany,
    required this.alumniPhotoUrl,
    required this.answer,
    this.isBestAnswer = false,
    required this.upvotes,
    required this.answeredAt,
  });
}

// ─── Event ────────────────────────────────────────────────────────────────────
class EventModel {
  final String id;
  final String title;
  final String description;
  final String hostAlumniName;
  final String hostCompany;
  final DateTime eventDate;
  final String type; // 'webinar', 'workshop', 'career_talk', 'mockinterview'
  final int registeredCount;
  final bool isRsvped;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.hostAlumniName,
    required this.hostCompany,
    required this.eventDate,
    required this.type,
    required this.registeredCount,
    required this.isRsvped,
  });
}

// ─── Badge ────────────────────────────────────────────────────────────────────
class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isEarned;
  final String category;

  const BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isEarned,
    required this.category,
  });
}
