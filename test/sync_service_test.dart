import 'dart:convert';

import 'package:algofit/config/sync_config.dart';
import 'package:algofit/data/world2_stages.dart';
import 'package:algofit/models/guest_progress.dart';
import 'package:algofit/services/progress/sync_state_store.dart';
import 'package:algofit/services/progress_repository.dart';
import 'package:algofit/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _baseUrl = 'https://sync.test';
const _secret = 'test-secret';
const _guestId = 'guest-abc';

Future<(ProgressRepository, SyncStateStore)> _setup({int? seedUpdatedAt}) async {
  SharedPreferences.setMockInitialValues({'algofit:guestId': _guestId});
  final repo = await ProgressRepository.create();
  final prefs = await SharedPreferences.getInstance();
  final state = SyncStateStore(prefs);
  if (seedUpdatedAt != null) await state.setLocalUpdatedAt(seedUpdatedAt);
  return (repo, state);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  SyncService service(
    http.Client client, {
    String baseUrl = _baseUrl,
    String secret = _secret,
    int now = 5000,
    Duration debounce = const Duration(milliseconds: 5),
  }) =>
      SyncService(
        baseUrl: baseUrl,
        secret: secret,
        client: client,
        debounce: debounce,
        nowMs: () => now,
      );

  group('비활성(미주입)', () {
    test('baseUrl/secret 이 비면 enabled=false 이고 어떤 요청도 보내지 않는다', () async {
      final (repo, state) = await _setup();
      var called = false;
      final client = MockClient((_) async {
        called = true;
        return http.Response('', 200);
      });
      final svc = service(client, baseUrl: '', secret: '');
      expect(svc.enabled, isFalse);
      expect(await svc.pull(_guestId), isNull);
      await svc.startupSync(repo, state);
      expect(called, isFalse);
      svc.dispose();
    });
  });

  group('pull', () {
    test('200 이면 updatedAt/data 를 파싱한다, 올바른 Bearer 토큰을 보낸다', () async {
      final (_, _) = await _setup();
      String? sentAuth;
      String? sentPath;
      final client = MockClient((req) async {
        sentAuth = req.headers['Authorization'];
        sentPath = req.url.path;
        return http.Response(
          jsonEncode({
            'guestId': _guestId,
            'updatedAt': 1234,
            'data': {'xp': 7},
          }),
          200,
        );
      });
      final svc = service(client);
      final pulled = await svc.pull(_guestId);
      expect(pulled, isNotNull);
      expect(pulled!.updatedAt, 1234);
      expect(pulled.data['xp'], 7);
      expect(sentAuth, 'Bearer ${syncToken(_guestId, secret: _secret)}');
      expect(sentPath, '/v1/progress/$_guestId');
      svc.dispose();
    });

    test('404 면 null', () async {
      final client = MockClient((_) async => http.Response('{}', 404));
      final svc = service(client);
      expect(await svc.pull(_guestId), isNull);
      svc.dispose();
    });

    test('네트워크 예외면 null (앱 동작 방해 없음)', () async {
      final client = MockClient((_) async => throw Exception('offline'));
      final svc = service(client);
      expect(await svc.pull(_guestId), isNull);
      svc.dispose();
    });
  });

  group('push', () {
    test('updatedAt/data 본문을 보내고 200 이면 true', () async {
      final (repo, state) = await _setup(seedUpdatedAt: 3000);
      Map<String, dynamic>? body;
      final client = MockClient((req) async {
        body = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(req.body, 200);
      });
      final svc = service(client);
      final ok = await svc.push(_guestId, repo, state);
      expect(ok, isTrue);
      expect(body!['updatedAt'], 3000);
      expect(body!['data'], isA<Map>());
      expect((body!['data'] as Map)['guestId'], _guestId);
      svc.dispose();
    });

    test('동기화 이력이 없으면(0) now 로 stamp 해서 올린다', () async {
      final (repo, state) = await _setup();
      Map<String, dynamic>? body;
      final client = MockClient((req) async {
        body = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(req.body, 200);
      });
      final svc = service(client, now: 9999);
      await svc.push(_guestId, repo, state);
      expect(body!['updatedAt'], 9999);
      expect(state.localUpdatedAt, 9999);
      svc.dispose();
    });

    test('409 면 서버 current 를 로컬에 채택하고 false', () async {
      final (repo, state) = await _setup(seedUpdatedAt: 1000);
      final serverData =
          GuestProgress(guestId: _guestId, level: 7, xp: 999).toJson();
      final client = MockClient((req) async {
        return http.Response(
          jsonEncode({
            'error': 'stale',
            'current': {
              'guestId': _guestId,
              'updatedAt': 8000,
              'data': serverData,
            },
          }),
          409,
        );
      });
      final svc = service(client);
      final ok = await svc.push(_guestId, repo, state);
      expect(ok, isFalse);
      expect(repo.progress.level, 7);
      expect(repo.progress.xp, 999);
      expect(state.localUpdatedAt, 8000);
      svc.dispose();
    });
  });

  group('startupSync', () {
    test('서버가 더 최신이면 로컬을 교체한다', () async {
      final (repo, state) = await _setup(seedUpdatedAt: 1000);
      final serverData =
          GuestProgress(guestId: _guestId, level: 9, xp: 50).toJson();
      final client = MockClient((req) async {
        if (req.method == 'GET') {
          return http.Response(
            jsonEncode({'guestId': _guestId, 'updatedAt': 5000, 'data': serverData}),
            200,
          );
        }
        return http.Response(req.body, 200);
      });
      final svc = service(client);
      await svc.startupSync(repo, state);
      expect(repo.progress.level, 9);
      expect(state.localUpdatedAt, 5000);
      svc.dispose();
    });

    test('서버가 더 오래됐거나 없으면 로컬을 올린다(GET 404 → PUT)', () async {
      final (repo, state) = await _setup(seedUpdatedAt: 7000);
      var didPut = false;
      final client = MockClient((req) async {
        if (req.method == 'GET') return http.Response('{}', 404);
        didPut = true;
        return http.Response(req.body, 200);
      });
      final svc = service(client);
      await svc.startupSync(repo, state);
      expect(didPut, isTrue);
      svc.dispose();
    });
  });

  group('변경 구독(디바운스 push)', () {
    test('진행이 바뀌면 디바운스 후 서버로 push 된다', () async {
      final (repo, state) = await _setup(seedUpdatedAt: 1000);
      var putCount = 0;
      final client = MockClient((req) async {
        if (req.method == 'GET') return http.Response('{}', 404);
        putCount++;
        return http.Response(req.body, 200);
      });
      final svc = service(client, debounce: const Duration(milliseconds: 5));
      await svc.startupSync(repo, state); // 초기 push 1회(GET 404 → PUT)
      final initial = putCount;

      repo.recordScenarioAnswer(isCorrect: true); // 진행 변경 → _onChange
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(putCount, greaterThan(initial));
      svc.dispose();
    });

    test('리스너 활성 경로의 409 채택이 트리거한 notifyListeners 는 재푸시하지 않는다(루프 차단)',
        () async {
      // 핵심: 409→채택을 startupSync 의 "초기 push"(리스너 부착 전)가 아니라
      // 실제 운영 경로인 "디바운스 push"(리스너 활성) 에서 일으켜야 _suppress 를 검증한다.
      final (repo, state) = await _setup(seedUpdatedAt: 1000);
      // schemaVersion 기본값 6 → adoptSyncedProgress 가 실제로 채택을 수행한다(>=6 요구).
      final serverData =
          GuestProgress(guestId: _guestId, level: 7, xp: 999).toJson();
      var putCount = 0;
      final client = MockClient((req) async {
        if (req.method == 'GET') return http.Response('{}', 404);
        putCount++;
        // 1번째 PUT(초기 startup push)=200 → 리스너가 정상 부착되도록 한다.
        // 2번째 PUT(로컬 변경 후 디바운스 push)=409 → 리스너 활성 상태에서 채택 유발.
        if (putCount == 2) {
          return http.Response(
            jsonEncode({
              'error': 'stale',
              'current': {
                'guestId': _guestId,
                'updatedAt': 8000,
                'data': serverData,
              },
            }),
            409,
          );
        }
        return http.Response(req.body, 200);
      });
      final svc = service(client, debounce: const Duration(milliseconds: 5));
      // 초기 push(GET 404 → PUT#1=200) 후 repo.addListener(_onChange) 가 부착된다.
      await svc.startupSync(repo, state);
      expect(putCount, 1);
      final afterStartup = putCount;

      // 로컬 변경 → _onChange(리스너 활성) → 디바운스 PUT#2 예약.
      repo.recordScenarioAnswer(isCorrect: true);
      // 디바운스보다 길게 대기 → PUT#2(=409) 실행 → _adopt → notifyListeners.
      // 채택 중 _suppress 가 _onChange 의 재예약을 막아야 한다.
      await Future<void>.delayed(const Duration(milliseconds: 30));

      // PUT#2(409) 한 번만 일어나고 채택이 유발한 notify 로 인한 PUT#3 은 없어야 한다.
      // (_suppress 가 제거되면 채택의 notifyListeners 가 _onChange→디바운스 PUT 을
      //  다시 예약해 putCount 가 3 이 되어 이 단언이 실패한다 = 진짜 회귀 가드.)
      expect(putCount, afterStartup + 1,
          reason: 'adopt-triggered notifyListeners must be suppressed');
      expect(repo.progress.level, 7); // 채택됨
      svc.dispose();
    });
  });

  group('adopt 정규화/검증', () {
    test('world2Nodes 길이가 다른 서버 데이터를 채택하면 콘텐츠 스테이지 수로 정규화된다', () async {
      final (repo, state) = await _setup(seedUpdatedAt: 1000);
      // 서버가 world2Nodes 를 10개만 보냈다(콘텐츠 스테이지 수=15 와 불일치).
      final shortNodes = List<String>.filled(10, 'locked');
      final serverData = GuestProgress(guestId: _guestId, level: 4).toJson()
        ..['world2Nodes'] = shortNodes;
      final client = MockClient((req) async {
        if (req.method == 'GET') {
          return http.Response(
            jsonEncode(
              {'guestId': _guestId, 'updatedAt': 5000, 'data': serverData},
            ),
            200,
          );
        }
        return http.Response(req.body, 200);
      });
      final svc = service(client);
      await svc.startupSync(repo, state);
      expect(repo.progress.level, 4); // 채택됨
      // adopt 가 정규화 경로를 거쳤음을 증명: 길이가 콘텐츠 스테이지 수로 보정됨.
      expect(repo.progress.world2Nodes.length, world2TotalStages);
      svc.dispose();
    });

    test('웹 유사 blob(schemaVersion 5/누락)은 거부되어 로컬 진행이 바뀌지 않는다', () async {
      final (repo, state) = await _setup(seedUpdatedAt: 1000);
      final localLevel = repo.progress.level;
      // 웹 클라이언트의 schema-v5 blob(모바일은 >=6 만 허용).
      final webBlob = GuestProgress(guestId: _guestId, level: 99, xp: 1234).toJson()
        ..['schemaVersion'] = 5;
      final client = MockClient((req) async {
        if (req.method == 'GET') {
          return http.Response(
            jsonEncode(
              {'guestId': _guestId, 'updatedAt': 5000, 'data': webBlob},
            ),
            200,
          );
        }
        return http.Response(req.body, 200);
      });
      final svc = service(client);
      await svc.startupSync(repo, state);
      // 거부되었으므로 로컬 진행은 그대로(level 99 로 덮어쓰이지 않음).
      expect(repo.progress.level, localLevel);
      expect(repo.progress.xp, isNot(1234));
      svc.dispose();
    });
  });
}
