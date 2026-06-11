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
///
/// 위협 모델(수용됨):
/// - 시크릿(`SYNC_SECRET`)이 바이너리에 임베드되므로 디컴파일로 추출 가능하다.
/// - 토큰은 만료가 없다(시간/세션 바인딩 없음).
/// 따라서 이 토큰은 강한 인증이 아니라, 자체 호스팅 서버에서 "비민감성 게스트 진행"의
/// 캐주얼한 덮어쓰기만 막는 게이트다. 민감 데이터는 동기화하지 않으므로 이 수준을 수용한다.
/// 노출/유출 시 `SYNC_SECRET` 을 로테이션하면 기존 모든 클라이언트 토큰이 한 번에 무효화된다
/// (재배포 필요). 인증 스킴 변경 없이 이 위협 모델을 문서로 수용한다.
String syncToken(String guestId, {String secret = kSyncSecret}) =>
    Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(guestId)).toString();
