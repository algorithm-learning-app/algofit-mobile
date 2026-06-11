import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 서버 동기화 기본 URL.
/// - 비활성(기본): 빈 문자열 → 동기화 자체를 끈다(현재 출시 동작 무변경).
/// - 활성: `--dart-define=SYNC_BASE_URL=https://api.example.com`
const kSyncBaseUrl = String.fromEnvironment('SYNC_BASE_URL', defaultValue: '');

/// 동기화 토큰 서명 시크릿 (`--dart-define=SYNC_SECRET=...`).
/// algofit-server 의 `SYNC_SECRET` 과 동일해야 한다.
const kSyncSecret = String.fromEnvironment('SYNC_SECRET', defaultValue: '');

/// baseUrl·secret 이 모두 주입됐을 때만 동기화를 켠다.
bool get syncEnabled => kSyncBaseUrl.isNotEmpty && kSyncSecret.isNotEmpty;

/// 서버 인증 토큰 = HMAC-SHA256(secret, guestId) 의 hex.
/// 서버 `verifyToken` 과 동일한 스킴(만료 없음, secret 소유 증명).
String syncToken(String guestId, {String secret = kSyncSecret}) =>
    Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(guestId)).toString();
