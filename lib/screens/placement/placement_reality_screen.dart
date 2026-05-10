import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/firestore_providers.dart';
import '../../theme/app_colors.dart';

class PlacementRealityScreen extends ConsumerWidget {
  const PlacementRealityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(placementStatsProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Placement Reality 🎭',
        showBackButton: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                              'No sugar-coating. Real data and stories from Aditya alumni.',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textSecondary))
                          .animate()
                          .fadeIn(delay: 100.ms),
                      const SizedBox(height: 16),

                      // Statistics Overview Section
                      statsAsync.when(
                        data: (stats) => _StatsOverview(stats: stats),
                        loading: () => const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary)),
                        error: (e, _) => const SizedBox.shrink(),
                      ).animate().fadeIn(delay: 150.ms),

                      const SizedBox(height: 24),

                      // Disclaimer banner
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                        const Text('⚠️', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'These are real experiences from Aditya College alumni. Some are anonymous to protect privacy.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4),
                          ),
                        ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 24),
                      const Text('Alumni Insights & Stories',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) =>
                        _StoryCard(story: _PlacementStories.stories[i], index: i),
                    childCount: _PlacementStories.stories.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsOverview extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsOverview({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Placement Rate',
                value: '${stats['placementRate']}%',
                subtitle: 'Aditya Avg',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Avg Package',
                value: '₹${stats['avgPackage']}L',
                subtitle: 'Annual CTC',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Alumni',
                value: '${stats['totalAlumni']}+',
                subtitle: 'In Directory',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Companies',
                value: '${stats['companiesRepresented']}',
                subtitle: 'Hiring Partners',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value, subtitle;
  final Color color;
  const _StatCard(
      {required this.title,
      required this.value,
      required this.subtitle,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _PlacementStories {
  static const stories = [
    _Story(
      name: 'Ravi Kumar Reddy',
      company: 'Amazon',
      photoUrl: 'https://i.pravatar.cc/150?img=11',
      title: '12 rejections before Amazon',
      content:
          'I kept a rejection diary. TCS, Infosys, Wipro, 3 startups, 2 mid-level product companies, 2 service firms — all said no. Each rejection I noted down exactly what went wrong. By rejection #8, I had a list of 47 improvement points. Amazon interview was just applying those 47 lessons.',
      package: '₹18 LPA',
      isAnon: false,
    ),
    _Story(
      name: 'Anonymous (CSE 2022)',
      company: 'Service Company',
      photoUrl: 'https://i.pravatar.cc/150?img=50',
      title: 'The CGPA lie they sell you',
      content:
          'My CGPA was 9.1. I thought I had an advantage. Reality? Mass recruiters cared only about aptitude scores. Product companies cared about my GitHub. My CGPA literally came up zero times in any interview. Focus on real skills, not paper marks.',
      package: '₹7 LPA',
      isAnon: true,
    ),
    _Story(
      name: 'Priya Lakshmi Venkat',
      company: 'Zoho',
      photoUrl: 'https://i.pravatar.cc/150?img=5',
      title: 'Zoho said NO twice, YES third time',
      content:
          'First attempt: failed written test (didn\'t know SQL properly). Second attempt: cleared written but failed technical. Third attempt: I had built 3 real apps, knew SQL deeply, could explain every line of my code. Got ₹12 LPA. Zoho rewards genuinely skilled people — no shortcuts.',
      package: '₹12 LPA',
      isAnon: false,
    ),
    _Story(
      name: 'Anonymous (ECE 2021)',
      company: 'IT Company',
      photoUrl: 'https://i.pravatar.cc/150?img=30',
      title: 'Switching branches mid-college',
      content:
          'ECE 3rd year. Saw all CSE people getting 8+ LPA. Panic-started DSA in 3rd year. Got average results. Wish I had started in 1st or 2nd year. Or better — focused on embedded systems which I actually loved. Branch envy is real and destructive. Be honest with yourself about what you love.',
      package: '₹4.5 LPA',
      isAnon: true,
    ),
    _Story(
      name: 'Ajay Kumar Thota',
      company: 'Microsoft',
      photoUrl: 'https://i.pravatar.cc/150?img=8',
      title: 'From ₹3.5L to ₹42L in 7 years',
      content:
          'Year 1: TCS, ₹3.5 LPA, felt embarrassed. Year 3: Mid-product, ₹9 LPA, gaining confidence. Year 5: Started serious FAANG prep, 18 months of daily 3-hour sessions. Year 7: Microsoft offered ₹42 LPA. The secret? Compounding skills patiently, not comparing packages with batchmates.',
      package: '₹42 LPA',
      isAnon: false,
    ),
  ];
}

class _Story {
  final String name, company, photoUrl, title, content, package;
  final bool isAnon;
  const _Story(
      {required this.name,
      required this.company,
      required this.photoUrl,
      required this.title,
      required this.content,
      required this.package,
      required this.isAnon});
}

class _StoryCard extends StatefulWidget {
  final _Story story;
  final int index;
  const _StoryCard({required this.story, required this.index});

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.story;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: s.isAnon
                  ? AppColors.accent.withValues(alpha: 0.3)
                  : AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (s.isAnon)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.4)),
                          ),
                          child: const Center(
                              child:
                                  Text('🤫', style: TextStyle(fontSize: 22))),
                        )
                      else
                        CircleAvatar(
                            radius: 22,
                            backgroundImage: NetworkImage(s.photoUrl)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            Text(s.company,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(s.package,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(s.title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  AnimatedCrossFade(
                    firstChild: Text(s.content,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.6),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                    secondChild: Text(s.content,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.6)),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: 300.ms,
                  ),
                  const SizedBox(height: 8),
                  Text(_expanded ? 'Show less ▲' : 'Read full story ▼',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 100))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.1, end: 0, duration: 350.ms);
  }
}

