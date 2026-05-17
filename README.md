# 알고핏 모바일 (Flutter)

iOS·Android용 **모바일 앱**. Daily·스트릭·Pick/Blank 짧은 세션·홈·World 맵의 기준 구현입니다.

PC 웹(긴 Blank, 코딩, PC 보너스)은 [`../web/README.md`](../web/README.md)를 참고하세요.

## 실행

```bash
cd apps/mobile
flutter pub get
flutter run
```

시뮬레이터: `flutter devices` 후 `flutter run -d <device_id>`  
실기기: USB 디버깅(Android) 또는 Xcode( iOS ) 연결 후 동일

## 패키지

- Android/iOS: `com.algofit.algofit` (org `com.algofit`, project `algofit`)
- Material 3, 다크 테마 — 토큰은 `apps/web` 홈과 동일

## 현재 범위

| 포함 | 미포함 |
|------|--------|
| 홈 UI (스트릭, XP, Daily 카드, PC 보너스 안내, World 1, 하단 탭) | Daily 5문항 플로우 |
| 마스코트 에셋 (`assets/images/mascot/`) | 로컬 진행 저장 |

## 에셋

마스코트 원본: `design/assets/mascot/` — 앱에는 neutral PNG만 번들.
