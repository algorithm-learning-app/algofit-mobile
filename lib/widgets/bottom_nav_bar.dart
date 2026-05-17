import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class AlgofitBottomNavBar extends StatelessWidget {
  const AlgofitBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  final int currentIndex;

  static const _tabs = [
    (path: '/home', icon: Icons.home_rounded, label: '홈'),
    (path: '/world/1', icon: Icons.menu_book_rounded, label: '학습'),
    (path: '/review', icon: Icons.replay_rounded, label: '복습'),
    (path: '/algorithm', icon: Icons.hub_rounded, label: '알고리즘'),
  ];

  static int indexForLocation(String location) {
    if (location.startsWith('/world')) return 1;
    if (location.startsWith('/review')) return 2;
    if (location.startsWith('/algorithm')) return 3;
    if (location.startsWith('/home')) return 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        context.go(_tabs[index].path);
      },
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
