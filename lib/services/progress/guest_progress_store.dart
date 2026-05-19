import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/world_catalog.dart';
import '../../models/guest_progress.dart';

const _progressKey = 'algofit:guestProgress';
const _guestIdKey = 'algofit:guestId';

String getTodaySeoul() {
  final now = DateTime.now().toUtc().add(const Duration(hours: 9));
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class GuestProgressStore {
  GuestProgressStore(this._prefs);

  final SharedPreferences _prefs;
  GuestProgress value = GuestProgress();

  Future<GuestProgress> loadAndNormalize() async {
    final guestId = _ensureGuestId();
    final today = getTodaySeoul();
    final raw = _prefs.getString(_progressKey);

    if (raw == null) {
      value = GuestProgress(guestId: guestId);
    } else {
      try {
        value = GuestProgress.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        value = GuestProgress(guestId: guestId);
      }
    }

    value = _normalizeWorld2Nodes(
      _resetDailyIfNewDay(value, today).copyWith(guestId: guestId),
    );
    await persist();
    return value;
  }

  Future<void> persist() async {
    await _prefs.setString(_progressKey, jsonEncode(value.toJson()));
  }

  String _ensureGuestId() {
    var id = _prefs.getString(_guestIdKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      _prefs.setString(_guestIdKey, id);
    }
    return id;
  }

  GuestProgress _normalizeWorld2Nodes(GuestProgress p) {
    final def = worldById(2);
    if (def == null) return p;

    final target = def.mapStageCount;
    var nodes = List<WorldNodeState>.from(p.world2Nodes);
    if (nodes.length == target) return p;

    if (nodes.length > target) {
      return p.copyWith(world2Nodes: nodes.sublist(0, target));
    }

    final oldLen = nodes.length;
    final allOldCleared =
        oldLen > 0 && nodes.every((n) => n == WorldNodeState.cleared);
    while (nodes.length < target) {
      nodes.add(WorldNodeState.locked);
    }
    if (allOldCleared && oldLen < target) {
      nodes[oldLen] = WorldNodeState.current;
    }
    return p.copyWith(world2Nodes: nodes);
  }

  GuestProgress _resetDailyIfNewDay(GuestProgress p, String today) {
    if (p.lastDailyDate == null || p.lastDailyDate == today) {
      return p;
    }
    return p.copyWith(
      todayDailyCompleted: false,
      todayAllCorrect: false,
      dailyProgress: 0,
      hearts: 5,
    );
  }
}
