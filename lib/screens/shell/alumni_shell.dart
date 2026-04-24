import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';

class AlumniShell extends ConsumerWidget {
  final Widget child;
  const AlumniShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(alumniNavIndexProvider);

    final tabs = [
      _NavTab(icon: Icons.dashboard_rounded, label: 'Dashboard', path: '/alumni-home'),
      _NavTab(icon: Icons.question_answer_rounded, label: 'Questions', path: '/alumni-questions'),
      _NavTab(icon: Icons.person_rounded, label: 'Profile', path: '/alumni-profile'),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.alumni.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(tabs.length, (i) {
                final isSelected = currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(alumniNavIndexProvider.notifier).state = i;
                      context.go(tabs[i].path);
                    },
                    child: AnimatedContainer(
                      duration: 250.ms,
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tabs[i].icon,
                            size: isSelected ? 24 : 22,
                            color: isSelected ? AppColors.alumni : AppColors.textMuted,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.alumni : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label, path;
  const _NavTab({required this.icon, required this.label, required this.path});
}
