import 'package:shared_preferences/shared_preferences.dart';

/// 서버 동기화 메타데이터(로컬 진행이 마지막으로 바뀐 시각)를 보관한다.
/// 진행 blob(GuestProgress) 과 분리해 저장하므로 GuestProgress 스키마는 건드리지 않는다.
class SyncStateStore {
  SyncStateStore(this._prefs);

  final SharedPreferences _prefs;
  static const _updatedAtKey = 'algofit:sync:updatedAt';

  /// 로컬 진행이 마지막으로 변경된 시각(epoch ms). 동기화 이력이 없으면 0.
  int get localUpdatedAt => _prefs.getInt(_updatedAtKey) ?? 0;

  Future<void> setLocalUpdatedAt(int ms) =>
      _prefs.setInt(_updatedAtKey, ms);
}
