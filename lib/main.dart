import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/sync_config.dart';
import 'router/app_router.dart';
import 'services/notification_service.dart';
import 'services/progress/sync_state_store.dart';
import 'services/progress_repository.dart';
import 'services/sync_service.dart';
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

  // 서버 동기화는 SYNC_BASE_URL/SYNC_SECRET 이 주입됐을 때만 동작한다(미주입 시 무동작).
  // 인스턴스를 보유해 AlgofitApp 에 주입하고, 위젯이 수명을 소유(dispose)한다.
  SyncService? syncService;
  if (syncEnabled) {
    try {
      final prefs = await SharedPreferences.getInstance();
      syncService = SyncService(baseUrl: kSyncBaseUrl, secret: kSyncSecret);
      await syncService.startupSync(repo, SyncStateStore(prefs));
    } catch (e, st) {
      debugPrint('guest progress sync init failed: $e\n$st');
    }
  }

  runApp(AlgofitApp(repo: repo, syncService: syncService));
}

class AlgofitApp extends StatefulWidget {
  const AlgofitApp({super.key, required this.repo, this.syncService});

  final ProgressRepository repo;

  /// 동기화 비활성(미주입) 시 null. 활성 시 위젯이 수명을 소유한다.
  final SyncService? syncService;

  @override
  State<AlgofitApp> createState() => _AlgofitAppState();
}

class _AlgofitAppState extends State<AlgofitApp> {
  late final GoRouter _router = createAppRouter(widget.repo);

  @override
  void dispose() {
    widget.syncService?.dispose();
    super.dispose();
  }

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
