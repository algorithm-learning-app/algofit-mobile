import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/guest_progress.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';

/// 홈 UI 시연용 목 데이터 (로컬 저장 연동 전).
const _demoProgress = GuestProgress(
  streakCount: 5,
  xp: 42,
  dailyProgress: 2,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1E293B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AlgofitApp());
}

class AlgofitApp extends StatelessWidget {
  const AlgofitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '알고핏',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeScreen(progress: _demoProgress),
    );
  }
}
