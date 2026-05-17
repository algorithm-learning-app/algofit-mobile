import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AlgofitBottomNavBar extends StatelessWidget {
  const AlgofitBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  final int currentIndex;

  static const _tabs = [
    (icon: Icons.home_rounded, label: '홈'),
    (icon: Icons.menu_book_rounded, label: '학습'),
    (icon: Icons.person_rounded, label: '프로필'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (_) {},
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withValues(alpha: 0.2),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        for (final tab in _tabs)
          NavigationDestination(
            icon: Icon(tab.icon, color: AppColors.muted),
            selectedIcon: Icon(tab.icon, color: AppColors.primary),
            label: tab.label,
          ),
      ],
    );
  }
}
