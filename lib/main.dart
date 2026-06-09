import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'router/app_router.dart';
import 'services/notification_service.dart';
import 'services/progress_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1E293B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final repo = await ProgressRepository.create();

  try {
    await NotificationService.instance.init();
    final progress = repo.progress;
    if (progress.dailyReminderEnabled) {
      await NotificationService.instance.scheduleDailyReminder(
        hour: progress.reminderHour,
        minute: progress.reminderMinute,
      );
    }
  } catch (e, st) {
    debugPrint('daily reminder init/schedule failed: $e\n$st');
  }

  runApp(AlgofitApp(repo: repo));
}

class AlgofitApp extends StatefulWidget {
  const AlgofitApp({super.key, required this.repo});

  final ProgressRepository repo;

  @override
  State<AlgofitApp> createState() => _AlgofitAppState();
}

class _AlgofitAppState extends State<AlgofitApp> {
  late final GoRouter _router = createAppRouter(widget.repo);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '알고핏',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}
