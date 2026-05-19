import 'package:algofit/config/pc_handoff.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('handoff 토큰은 guestId를 복원하고 만료 전에는 유효하다', () {
    const guestId = 'test-guest-uuid';
    final token = createHandoffToken(guestId);
    expect(token, isNot(contains(guestId)));
    expect(verifyHandoffToken(token), guestId);
  });

  test('handoff 토큰은 변조 시 null', () {
    final token = createHandoffToken('abc');
    expect(verifyHandoffToken('${token}x'), isNull);
  });
}
