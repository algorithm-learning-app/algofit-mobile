import 'package:algofit/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nextInstanceOf', () {
    test('오늘 아직 남은 시간이면 오늘로 예약된다', () {
      final now = DateTime(2026, 6, 10, 9, 0);
      final next = nextInstanceOf(20, 0, now);
      expect(next, DateTime(2026, 6, 10, 20, 0));
    });

    test('이미 지난 시간이면 내일로 예약된다', () {
      final now = DateTime(2026, 6, 10, 21, 0);
      final next = nextInstanceOf(20, 0, now);
      expect(next, DateTime(2026, 6, 11, 20, 0));
    });

    test('정확히 지금이면 엄격히 이후인 내일로 예약된다', () {
      final now = DateTime(2026, 6, 10, 20, 0);
      final next = nextInstanceOf(20, 0, now);
      expect(next, DateTime(2026, 6, 11, 20, 0));
    });
  });
}
