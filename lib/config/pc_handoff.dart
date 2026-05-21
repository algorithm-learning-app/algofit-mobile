import 'dart:convert';

import 'package:crypto/crypto.dart';

/// PC 웹 이어하기 기본 URL.
/// - 로컬: `--dart-define=PC_WEB_BASE_URL=http://localhost:5174`
/// - 출시: `https://...` (HTTPS 필수)
const kPcWebBaseUrl = String.fromEnvironment(
  'PC_WEB_BASE_URL',
  defaultValue: 'https://localhost:5174',
);

/// HMAC 서명용 시크릿 (`--dart-define=HANDOFF_SECRET=...`).
const _handoffSecret = String.fromEnvironment(
  'HANDOFF_SECRET',
  defaultValue: 'algofit-dev-handoff-secret',
);

const _handoffTtl = Duration(minutes: 5);

/// guestId·exp 구분자 (guestId에 `.`이 들어가도 파싱이 깨지지 않도록 고정).
const _handoffFieldSep = '|';

/// guestId 대신 서명된 단기 handoff 토큰을 발급한다.
String createHandoffToken(String guestId) {
  final exp =
      DateTime.now().toUtc().add(_handoffTtl).millisecondsSinceEpoch;
  final payload = '$guestId$_handoffFieldSep$exp';
  final mac = Hmac(sha256, utf8.encode(_handoffSecret))
      .convert(utf8.encode(payload))
      .toString();
  return base64Url.encode(utf8.encode('$payload.$mac'));
}

/// PC 웹 `/continue?handoff=...` URL.
String pcContinueUrl(String handoffToken) =>
    '$kPcWebBaseUrl/continue?handoff=${Uri.encodeComponent(handoffToken)}';

/// PC 웹에서 handoff 토큰을 검증해 guestId를 복원한다 (동일 시크릿 필요).
String? verifyHandoffToken(String token) {
  try {
    final decoded = utf8.decode(base64Url.decode(token));
    final lastDot = decoded.lastIndexOf('.');
    if (lastDot <= 0) return null;

    final payload = decoded.substring(0, lastDot);
    final mac = decoded.substring(lastDot + 1);
    final expected = Hmac(sha256, utf8.encode(_handoffSecret))
        .convert(utf8.encode(payload))
        .toString();
    if (mac != expected) return null;

    final guestSep = payload.lastIndexOf(_handoffFieldSep);
    if (guestSep <= 0) return null;

    final guestId = payload.substring(0, guestSep);
    final exp = int.tryParse(payload.substring(guestSep + 1));
    if (exp == null || DateTime.now().toUtc().millisecondsSinceEpoch > exp) {
      return null;
    }
    return guestId;
  } catch (_) {
    return null;
  }
}
