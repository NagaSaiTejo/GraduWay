import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';

class StudentShell extends ConsumerWidget {
  final Widget child;
  const StudentShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(studentNavIndexProvider);

    final tabs = [
      _NavTab(icon: Icons.home_rounded, label: 'Home', path: '/home'),
      _NavTab(icon: Icons.people_alt_rounded, label: 'Alumni', path: '/alumni'),
      _NavTab(icon: Icons.quiz_rounded, label: 'Ask', path: '/qa'),
      _NavTab(icon: Icons.map_rounded, label: 'Roadmap', path: '/roadmap'),
      _NavTab(icon: Icons.emoji_events_rounded, label: 'Badges', path: '/badges'),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hidden by default, screens will provide their own or we add one here
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
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
                      ref.read(studentNavIndexProvider.notifier).state = i;
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
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textMuted,
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
