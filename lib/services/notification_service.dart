import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// hour:minute에 맞춰 `now`보다 엄격히 이후인(즉, 정확히 지금이면 내일) 가장 가까운
/// DateTime을 반환한다. 플러그인 없이 단독으로 단위 테스트 가능한 순수 함수.
DateTime nextInstanceOf(int hour, int minute, DateTime now) {
  var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
  if (!scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

/// Daily 리마인드 로컬 알림 1001번을 관리한다. 백엔드 없이 기기 내 스케줄만 사용.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// 앱 전역에서 공유하는 인스턴스. main()에서 init() 후 Profile 등에서 사용.
  static final NotificationService instance = NotificationService();

  static const int _reminderId = 1001;
  static const String _channelId = 'daily_reminder';
  static const String _channelName = '일일 리마인드';

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> init() async {
    tz.initializeTimeZones();
    final localName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localName));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
    );
  }

  /// Android 13+ / iOS 알림 권한을 요청한다. 구버전 Android(null 반환)는 허용으로 간주.
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      // Android <13은 런타임 알림 권한 자체가 없어 plugin이 null을 반환하므로
      // 허용(true)으로 간주한다. Android 13+에서는 실제 grant 결과(bool)가 반환된다.
      final granted = await android.requestNotificationsPermission();
      return granted ?? true;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await cancelDailyReminder();
    final next = nextInstanceOf(hour, minute, DateTime.now());
    final scheduled = tz.TZDateTime.from(next, tz.local);

    await _plugin.zonedSchedule(
      _reminderId,
      '알고핏',
      '오늘의 챌린지를 풀 시간이에요! 스트릭을 이어가세요 🔥',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // inexact — SCHEDULE_EXACT_ALARM 권한이 필요 없도록 비정확 스케줄 사용.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() => _plugin.cancel(_reminderId);
}
