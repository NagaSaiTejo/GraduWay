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
