import '../models/daily_question.dart';

class QuestionPools {
  const QuestionPools({required this.picks, required this.blanks});

  final List<PickQuestion> picks;
  final List<BlankQuestion> blanks;
}

/// Daily 문항 풀·오늘 팩 메모리 캐시 (테스트·언어 변경 시 무효화).
class QuestionPoolCache {
  QuestionPoolCache._();

  static final QuestionPoolCache instance = QuestionPoolCache._();

  DailyPack? _dailyPack;
  String? _dailyPackDateKey;
  String? _dailyPackLanguage;
  QuestionPools? _pools;

  DailyPack? get dailyPack => _dailyPack;
  String? get dailyPackDateKey => _dailyPackDateKey;
  String? get dailyPackLanguage => _dailyPackLanguage;
  QuestionPools? get pools => _pools;

  void setDailyPack({
    required DailyPack pack,
    required String dateKey,
    required String language,
  }) {
    _dailyPack = pack;
    _dailyPackDateKey = dateKey;
    _dailyPackLanguage = language;
  }

  void setPools(QuestionPools pools) {
    _pools = pools;
  }

  /// 선호 언어 변경 시 오늘 팩만 다시 구성.
  void invalidateDailyPack() {
    _dailyPack = null;
    _dailyPackDateKey = null;
    _dailyPackLanguage = null;
  }

  /// 테스트·핫 리로드용 전체 초기화.
  void resetAll() {
    _dailyPack = null;
    _dailyPackDateKey = null;
    _dailyPackLanguage = null;
    _pools = null;
  }
}
