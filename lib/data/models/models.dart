import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String askedBy; // student name
  final String askedById; // student id
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

  /// Create a [QAModel] from a Firestore document snapshot.
  factory QAModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QAModel(
      id: doc.id,
      question: data['question'] as String? ?? '',
      askedBy: data['askedBy'] as String? ?? 'Anonymous',
      askedById: data['askedById'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      tags: List<String>.from(data['tags'] as List? ?? []),
      answers: [], // loaded separately from sub-collection
      isAnswered: data['isAnswered'] as bool? ?? false,
    );
  }

  /// Create a [QAModel] from a plain Map (local state / MongoDB).
  factory QAModel.fromMap(Map<String, dynamic> data, {String? id}) {
    return QAModel(
      id: id ?? data['id'] as String? ?? '',
      question: data['question'] as String? ?? '',
      askedBy: data['askedBy'] as String? ?? 'Anonymous',
      askedById: data['askedById'] as String? ?? '',
      timestamp: data['timestamp'] is DateTime
          ? data['timestamp'] as DateTime
          : DateTime.now(),
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      tags: List<String>.from(data['tags'] as List? ?? []),
      answers: const [],
      isAnswered: data['isAnswered'] as bool? ?? false,
    );
  }

  QAModel copyWith({int? upvotes, List<QAAnswer>? answers, bool? isAnswered}) {
    return QAModel(
      id: id,
      question: question,
      askedBy: askedBy,
      askedById: askedById,
      timestamp: timestamp,
      upvotes: upvotes ?? this.upvotes,
      tags: tags,
      answers: answers ?? this.answers,
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }
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

  factory QAAnswer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QAAnswer(
      id: doc.id,
      alumniId: data['alumniId'] as String? ?? '',
      alumniName: data['alumniName'] as String? ?? 'Alumni',
      alumniCompany: data['alumniCompany'] as String? ?? '',
      alumniPhotoUrl: data['alumniPhotoUrl'] as String? ?? '',
      answer: data['answer'] as String? ?? '',
      isBestAnswer: data['isBestAnswer'] as bool? ?? false,
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      answeredAt:
          (data['answeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
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

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      hostAlumniName: data['hostAlumniName'] as String? ?? '',
      hostCompany: data['hostCompany'] as String? ?? '',
      eventDate: (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] as String? ?? 'webinar',
      registeredCount: (data['registeredCount'] as num?)?.toInt() ?? 0,
      isRsvped: data['isRsvped'] as bool? ?? false,
    );
  }

  EventModel copyWith({int? registeredCount, bool? isRsvped}) {
    return EventModel(
      id: id,
      title: title,
      description: description,
      hostAlumniName: hostAlumniName,
      hostCompany: hostCompany,
      eventDate: eventDate,
      type: type,
      registeredCount: registeredCount ?? this.registeredCount,
      isRsvped: isRsvped ?? this.isRsvped,
    );
  }
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
