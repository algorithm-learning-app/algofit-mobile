import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/daily_session.dart';

const _dailySessionKey = 'algofit:dailySession';

class DailySessionStore {
  DailySessionStore(this._prefs);

  final SharedPreferences _prefs;
  DailySession? value;

  DailySession? loadFromDisk() {
    final sessionRaw = _prefs.getString(_dailySessionKey);
    if (sessionRaw == null) return null;
    try {
      value = DailySession.fromJson(
        jsonDecode(sessionRaw) as Map<String, dynamic>,
      );
      return value;
    } catch (_) {
      value = null;
      return null;
    }
  }

  Future<void> persist(DailySession session) async {
    value = session;
    await _prefs.setString(_dailySessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clear() async {
    value = null;
    await _prefs.remove(_dailySessionKey);
  }
}
