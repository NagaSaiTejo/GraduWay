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
