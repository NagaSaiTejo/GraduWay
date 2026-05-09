export 'student_model.dart';
export 'alumni_model.dart';
export 'admin_model.dart';

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

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'alumniId': alumniId,
      'alumniName': alumniName,
      'alumniCompany': alumniCompany,
      'alumniPhotoUrl': alumniPhotoUrl,
      'content': content,
      'type': type,
      'tags': tags,
      'likes': likes,
      'saves': saves,
      'isAnonymous': isAnonymous,
      'postedAt': postedAt.toIso8601String(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['_id'] ?? '',
      alumniId: map['alumniId'] ?? '',
      alumniName: map['alumniName'] ?? '',
      alumniCompany: map['alumniCompany'] ?? '',
      alumniPhotoUrl: map['alumniPhotoUrl'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      likes: map['likes'] ?? 0,
      saves: map['saves'] ?? 0,
      isAnonymous: map['isAnonymous'] ?? false,
      postedAt: map['postedAt'] != null ? DateTime.parse(map['postedAt']) : DateTime.now(),
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'question': question,
      'askedBy': askedBy,
      'askedById': askedById,
      'timestamp': timestamp.toIso8601String(),
      'upvotes': upvotes,
      'tags': tags,
      'answers': answers.map((x) => x.toMap()).toList(),
      'isAnswered': isAnswered,
    };
  }

  factory QAModel.fromMap(Map<String, dynamic> map) {
    return QAModel(
      id: map['_id'] ?? '',
      question: map['question'] ?? '',
      askedBy: map['askedBy'] ?? '',
      askedById: map['askedById'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      upvotes: map['upvotes'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      answers: List<QAAnswer>.from(map['answers']?.map((x) => QAAnswer.fromMap(x)) ?? []),
      isAnswered: map['isAnswered'] ?? false,
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

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'alumniId': alumniId,
      'alumniName': alumniName,
      'alumniCompany': alumniCompany,
      'alumniPhotoUrl': alumniPhotoUrl,
      'answer': answer,
      'isBestAnswer': isBestAnswer,
      'upvotes': upvotes,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  factory QAAnswer.fromMap(Map<String, dynamic> map) {
    return QAAnswer(
      id: map['_id'] ?? '',
      alumniId: map['alumniId'] ?? '',
      alumniName: map['alumniName'] ?? '',
      alumniCompany: map['alumniCompany'] ?? '',
      alumniPhotoUrl: map['alumniPhotoUrl'] ?? '',
      answer: map['answer'] ?? '',
      isBestAnswer: map['isBestAnswer'] ?? false,
      upvotes: map['upvotes'] ?? 0,
      answeredAt: map['answeredAt'] != null ? DateTime.parse(map['answeredAt']) : DateTime.now(),
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

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'hostAlumniName': hostAlumniName,
      'hostCompany': hostCompany,
      'eventDate': eventDate.toIso8601String(),
      'type': type,
      'registeredCount': registeredCount,
      'isRsvped': isRsvped,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      hostAlumniName: map['hostAlumniName'] ?? '',
      hostCompany: map['hostCompany'] ?? '',
      eventDate: map['eventDate'] != null ? DateTime.parse(map['eventDate']) : DateTime.now(),
      type: map['type'] ?? '',
      registeredCount: map['registeredCount'] ?? 0,
      isRsvped: map['isRsvped'] ?? false,
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
