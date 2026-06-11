import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/sync_config.dart';
import 'progress/sync_state_store.dart';
import 'progress_repository.dart';

/// 서버에서 받은 진행 1건.
class PulledProgress {
  const PulledProgress({required this.updatedAt, required this.data});
  final int updatedAt;
  final Map<String, dynamic> data;
}

/// 게스트 진행을 algofit-server 와 동기화한다.
///
/// - 시작 시 1회 [startupSync]: 서버가 더 최신이면 로컬을 교체, 아니면 로컬을 올린다.
/// - 이후 진행 변경마다 디바운스 push (서버에 더 최신본이 있으면 409 → 로컬 채택).
/// - 네트워크 오류·오프라인은 조용히 무시한다(앱 동작을 막지 않음).
class SyncService {
  SyncService({
    required this.baseUrl,
    required this.secret,
    http.Client? client,
    Duration debounce = const Duration(seconds: 4),
    int Function()? nowMs,
  })  : _client = client ?? http.Client(),
        _debounce = debounce,
        _now = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final String baseUrl;
  final String secret;
  final http.Client _client;
  final Duration _debounce;
  final int Function() _now;

  Timer? _timer;
  ProgressRepository? _repo;
  SyncStateStore? _state;
  // adopt 중에는 _onChange 의 push 스케줄을 막아 푸시 루프를 끊는다.
  bool _suppress = false;

  bool get enabled => baseUrl.isNotEmpty && secret.isNotEmpty;

  Uri _uri(String guestId) =>
      Uri.parse('$baseUrl/v1/progress/${Uri.encodeComponent(guestId)}');

  Map<String, String> _headers(String guestId) => {
        'Authorization': 'Bearer ${syncToken(guestId, secret: secret)}',
        'Content-Type': 'application/json',
      };

  /// 앱 시작 시 1회 호출. 이후 [repo] 변경을 구독해 디바운스 push 를 건다.
  Future<void> startupSync(
    ProgressRepository repo,
    SyncStateStore state,
  ) async {
    if (!enabled) return;
    _repo = repo;
    _state = state;

    final guestId = repo.progress.guestId;
    if (guestId.isNotEmpty) {
      final pulled = await pull(guestId);
      if (pulled != null && pulled.updatedAt > state.localUpdatedAt) {
        await _adopt(repo, state, pulled.data, pulled.updatedAt);
      } else {
        await push(guestId, repo, state);
      }
    }

    repo.addListener(_onChange);
  }

  void _onChange() {
    if (_suppress) return;
    final repo = _repo, state = _state;
    if (repo == null || state == null) return;
    // 로컬 변경 시각 갱신 + 디바운스 push.
    state.setLocalUpdatedAt(_now());
    _timer?.cancel();
    _timer = Timer(_debounce, () {
      push(repo.progress.guestId, repo, state);
    });
  }

  /// 서버에서 진행을 가져온다. 없거나(404) 오류면 null.
  Future<PulledProgress?> pull(String guestId) async {
    if (!enabled || guestId.isEmpty) return null;
    try {
      final res = await _client.get(_uri(guestId), headers: _headers(guestId));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final updatedAt = (body['updatedAt'] as num?)?.toInt();
      final data = body['data'];
      if (updatedAt == null || data is! Map) return null;
      return PulledProgress(
        updatedAt: updatedAt,
        data: data.cast<String, dynamic>(),
      );
    } catch (e) {
      debugPrint('sync pull failed: $e');
      return null;
    }
  }

  /// 현재 진행을 서버에 올린다. 200 이면 true, 409(서버가 더 최신)면 로컬 채택 후 false.
  Future<bool> push(
    String guestId,
    ProgressRepository repo,
    SyncStateStore state,
  ) async {
    if (!enabled || guestId.isEmpty) return false;

    // 서버는 updatedAt>0 만 허용. 동기화 이력이 없으면 지금 시각으로 stamp.
    var updatedAt = state.localUpdatedAt;
    if (updatedAt <= 0) {
      updatedAt = _now();
      await state.setLocalUpdatedAt(updatedAt);
    }

    try {
      final res = await _client.put(
        _uri(guestId),
        headers: _headers(guestId),
        body: jsonEncode({'updatedAt': updatedAt, 'data': repo.progress.toJson()}),
      );
      if (res.statusCode == 200) return true;
      if (res.statusCode == 409) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final current = body['current'];
        if (current is Map) {
          final data = current['data'];
          final serverUpdatedAt = (current['updatedAt'] as num?)?.toInt();
          if (data is Map && serverUpdatedAt != null) {
            await _adopt(
              repo,
              state,
              data.cast<String, dynamic>(),
              serverUpdatedAt,
            );
          }
        }
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('sync push failed: $e');
      return false;
    }
  }

  Future<void> _adopt(
    ProgressRepository repo,
    SyncStateStore state,
    Map<String, dynamic> data,
    int updatedAt,
  ) async {
    _suppress = true;
    try {
      await repo.adoptSyncedProgress(data);
      await state.setLocalUpdatedAt(updatedAt);
    } finally {
      _suppress = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    _repo?.removeListener(_onChange);
    _client.close();
  }
}
