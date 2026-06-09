import 'package:algofit/models/guest_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GuestProgress reminder 필드 마이그레이션', () {
    test('리마인드 필드 없는 v5 저장본은 기본값으로 로드되고 schema가 6으로 정규화된다', () {
      final v5Json = {
        'schemaVersion': 5,
        'guestId': 'test-guest',
        'preferredCodeLanguage': 'python',
        'level': 3,
      };

      final progress = GuestProgress.fromJson(v5Json);

      expect(progress.schemaVersion, 6);
      expect(progress.dailyReminderEnabled, false);
      expect(progress.reminderHour, 20);
      expect(progress.reminderMinute, 0);
      // 기존 필드는 손실 없이 유지된다.
      expect(progress.guestId, 'test-guest');
      expect(progress.preferredCodeLanguage, 'python');
      expect(progress.level, 3);
    });

    test('toJson은 리마인드 필드를 포함한다', () {
      final progress = GuestProgress(
        dailyReminderEnabled: true,
        reminderHour: 7,
        reminderMinute: 30,
      );
      final json = progress.toJson();

      expect(json['schemaVersion'], 6);
      expect(json['dailyReminderEnabled'], true);
      expect(json['reminderHour'], 7);
      expect(json['reminderMinute'], 30);
    });

    test('copyWith은 리마인드 필드를 갱신한다', () {
      final progress = GuestProgress();
      final updated = progress.copyWith(
        dailyReminderEnabled: true,
        reminderHour: 8,
        reminderMinute: 15,
      );

      expect(updated.dailyReminderEnabled, true);
      expect(updated.reminderHour, 8);
      expect(updated.reminderMinute, 15);
      // 원본은 변하지 않는다.
      expect(progress.dailyReminderEnabled, false);
      expect(progress.reminderHour, 20);
      expect(progress.reminderMinute, 0);
    });
  });
}
