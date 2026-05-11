import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/firestore_providers.dart';

class AdminOverviewScreen extends ConsumerWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(placementStatsProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Admin Console',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Platform Status',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            statsAsync.when(
              loading: () => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: const [
                  _StatCard(
                      label: 'Total Alumni',
                      value: '...',
                      icon: Icons.verified_user_rounded,
                      color: AppColors.alumni),
                  _StatCard(
                      label: 'Placement Rate',
                      value: '...',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.primary),
                  _StatCard(
                      label: 'Avg Package',
                      value: '...',
                      icon: Icons.currency_rupee_rounded,
                      color: AppColors.secondary),
                  _StatCard(
                      label: 'Companies',
                      value: '...',
                      icon: Icons.business_rounded,
                      color: AppColors.admin),
                ],
              ),
              data: (stats) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    label: 'Verified Alumni',
                    value: '${stats['totalAlumni'] ?? 0}',
                    icon: Icons.verified_user_rounded,
                    color: AppColors.alumni,
                  ),
                  _StatCard(
                    label: 'Placement Rate',
                    value: '${stats['placementRate'] ?? 0}%',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.primary,
                  ),
                  _StatCard(
                    label: 'Avg Package',
                    value: '₹${stats['avgPackage'] ?? 0}L',
                    icon: Icons.currency_rupee_rounded,
                    color: AppColors.secondary,
                  ),
                  _StatCard(
                    label: 'Companies',
                    value: '${stats['companiesRepresented'] ?? 0}',
                    icon: Icons.business_rounded,
                    color: AppColors.admin,
                  ),
                ],
              ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
              error: (_, __) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: const [
                  _StatCard(
                      label: 'Total Alumni',
                      value: '450+',
                      icon: Icons.verified_user_rounded,
                      color: AppColors.alumni),
                  _StatCard(
                      label: 'Placement Rate',
                      value: '94%',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.primary),
                  _StatCard(
                      label: 'Avg Package',
                      value: '₹12.5L',
                      icon: Icons.currency_rupee_rounded,
                      color: AppColors.secondary),
                  _StatCard(
                      label: 'Companies',
                      value: '120+',
                      icon: Icons.business_rounded,
                      color: AppColors.admin),
                ],
              ),
            ),
            const SizedBox(height: 32),
            statsAsync.maybeWhen(
              data: (stats) {
                final recruiters =
                    stats['topRecruiters'] as Map<String, dynamic>?;
                if (recruiters == null || recruiters.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Top Recruiters',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    ...recruiters.entries.take(5).map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${e.value} hires',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    const SizedBox(height: 32),
                  ],
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),
            const Text('Registration Trend',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1),
                        FlSpot(1, 3),
                        FlSpot(2, 2),
                        FlSpot(3, 5),
                        FlSpot(4, 3),
                        FlSpot(5, 7),
                        FlSpot(6, 8),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            const Text('System Reports',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _ReportTile(
              title: 'New Alumni Requests',
              count: '5',
              color: AppColors.alumni,
              icon: Icons.person_add_rounded,
              onTap: () => context.go('/admin-users'),
            ),
            const SizedBox(height: 12),
            _ReportTile(
              title: 'Reported Content',
              count: '2',
              color: AppColors.error,
              icon: Icons.flag_rounded,
              onTap: () => _showReportedContentSheet(context),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showReportedContentSheet(BuildContext context) {
    final reports = [
      {
        'user': 'Anon Student',
        'content': 'Inappropriate comment in Q&A thread',
        'time': '2h ago'
      },
      {
        'user': 'Alumni X',
        'content': 'Misleading salary data in profile',
        'time': '1 day ago'
      },
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Reported Content',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            ...reports.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.flag_rounded,
                                color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Text(r['user']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                            const Spacer(),
                            Text(r['time']!,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(r['content']!,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Dismiss'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Content removed.'),
                                        backgroundColor: AppColors.error),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error),
                                child: const Text('Remove'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String title, count;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  const _ReportTile(
      {required this.title,
      required this.count,
      required this.color,
      required this.icon,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(20)),
              child: Text(count,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
