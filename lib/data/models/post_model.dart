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
