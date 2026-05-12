import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_colors.dart';
import '../../providers/firestore_providers.dart';
import '../../providers/app_providers.dart';
import '../../data/models/models.dart';
import '../../widgets/custom_app_bar.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  // Local RSVP set for instant UI feedback (Firestore write happens async)
  final Set<String> _rsvped = {};

  @override
  void initState() {
    super.initState();
    // Pre-seed from any events that already have isRsvped = true
    // (populated from Firestore stream below via listener)
  }

  Future<void> _toggleRsvp(EventModel event) async {
    final wasRsvped = _rsvped.contains(event.id);
    // Optimistic update
    setState(() {
      if (wasRsvped) {
        _rsvped.remove(event.id);
      } else {
        _rsvped.add(event.id);
        // Award badge for first RSVP
        ref.read(studentProgressProvider.notifier).attendEvent();
      }
    });

    // Persist to Firestore
    try {
      final docRef =
          FirebaseFirestore.instance.collection('events').doc(event.id);
      await docRef.set({
        'isRsvped': !wasRsvped,
        'registeredCount': FieldValue.increment(wasRsvped ? -1 : 1),
      }, SetOptions(merge: true));
    } catch (_) {
      // Firestore write failed — revert optimistic update
      if (mounted) {
        setState(() {
          if (wasRsvped) {
            _rsvped.add(event.id);
          } else {
            _rsvped.remove(event.id);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsStreamProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Events & Webinars 📅',
        showBackButton: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: eventsAsync.when(
            loading: () => _buildShimmer(),
            error: (_, __) => _buildErrorState(),
            data: (events) {
              // Seed RSVP set from Firestore data (first time only)
              for (final e in events) {
                if (e.isRsvped && !_rsvped.contains(e.id)) {
                  _rsvped.add(e.id);
                }
              }

              if (events.isEmpty) return _buildEmptyState();

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${events.length} upcoming sessions hosted by Aditya alumni',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) =>
                            _EventCard(
                              event: events[i],
                              isRsvped: _rsvped.contains(events[i].id),
                              onRsvpToggle: () => _toggleRsvp(events[i]),
                              index: i,
                            ),
                        childCount: events.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCard,
      highlightColor: AppColors.bgCardLight,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          height: 200,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📅', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('No upcoming events',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 16)),
          SizedBox(height: 6),
          Text('Check back soon for new sessions by alumni',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('⚠️', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Could not load events',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

// ─── Event Card ──────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final EventModel event;
  final bool isRsvped;
  final VoidCallback onRsvpToggle;
  final int index;

  const _EventCard({
    required this.event,
    required this.isRsvped,
    required this.onRsvpToggle,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final typeEmojis = {
      'webinar': '📡',
      'workshop': '🛠️',
      'career_talk': '🎤',
      'mockinterview': '🎯',
    };
    final typeColors = {
      'webinar': AppColors.success,
      'workshop': AppColors.secondary,
      'career_talk': AppColors.primary,
      'mockinterview': AppColors.accent,
    };
    final color = typeColors[event.type] ?? AppColors.primary;
    final emoji = typeEmojis[event.type] ?? '📅';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isRsvped
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14)),
                  child: Center(
                      child:
                          Text(emoji, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                            event.type
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            style: TextStyle(
                                fontSize: 9,
                                color: color,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                      ),
                      const SizedBox(height: 4),
                      Text(event.title,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(event.description,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.person_rounded,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${event.hostAlumniName} · ${event.hostCompany}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 13, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('d MMM y · h:mm a').format(event.eventDate),
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.people_rounded,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('${event.registeredCount} registered',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GestureDetector(
              onTap: onRsvpToggle,
              child: AnimatedContainer(
                duration: 250.ms,
                height: 44,
                decoration: BoxDecoration(
                  gradient: isRsvped ? null : AppColors.primaryGradient,
                  color: isRsvped
                      ? AppColors.success.withValues(alpha: 0.15)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: isRsvped
                      ? Border.all(
                          color: AppColors.success.withValues(alpha: 0.4))
                      : null,
                  boxShadow: isRsvped
                      ? []
                      : [
                          BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10)
                        ],
                ),
                child: Center(
                  child: Text(
                    isRsvped ? '✅ RSVP\'d — See you there!' : 'RSVP for Free →',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isRsvped ? AppColors.success : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, duration: 400.ms);
  }
}
