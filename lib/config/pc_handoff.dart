/// PC 웹 이어하기 기본 URL (`--dart-define=PC_WEB_BASE_URL=...` 로 덮어쓰기).
const kPcWebBaseUrl = String.fromEnvironment(
  'PC_WEB_BASE_URL',
  defaultValue: 'http://localhost:5174',
);

String pcContinueUrl(String guestId) =>
    '$kPcWebBaseUrl/continue?token=${Uri.encodeComponent(guestId)}';
