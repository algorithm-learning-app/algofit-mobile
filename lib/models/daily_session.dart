class DailySession {
  const DailySession({
    required this.questionIndex,
    required this.answers,
    required this.hearts,
    required this.xpEarned,
    required this.awaitingFeedback,
    required this.lastAnswerCorrect,
    required this.startedAt,
  });

  factory DailySession.initial() {
    return DailySession(
      questionIndex: 0,
      answers: const [],
      hearts: 5,
      xpEarned: 0,
      awaitingFeedback: false,
      lastAnswerCorrect: null,
      startedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  factory DailySession.fromJson(Map<String, dynamic> json) {
    return DailySession(
      questionIndex: json['questionIndex'] as int,
      answers: (json['answers'] as List<dynamic>).map((e) => e as bool).toList(),
      hearts: json['hearts'] as int,
      xpEarned: json['xpEarned'] as int,
      awaitingFeedback: json['awaitingFeedback'] as bool,
      lastAnswerCorrect: json['lastAnswerCorrect'] as bool?,
      startedAt: json['startedAt'] as String,
    );
  }

  final int questionIndex;
  final List<bool> answers;
  final int hearts;
  final int xpEarned;
  final bool awaitingFeedback;
  final bool? lastAnswerCorrect;
  final String startedAt;

  Map<String, dynamic> toJson() => {
        'questionIndex': questionIndex,
        'answers': answers,
        'hearts': hearts,
        'xpEarned': xpEarned,
        'awaitingFeedback': awaitingFeedback,
        'lastAnswerCorrect': lastAnswerCorrect,
        'startedAt': startedAt,
      };

  DailySession copyWith({
    int? questionIndex,
    List<bool>? answers,
    int? hearts,
    int? xpEarned,
    bool? awaitingFeedback,
    bool? lastAnswerCorrect,
    bool clearLastAnswerCorrect = false,
  }) {
    return DailySession(
      questionIndex: questionIndex ?? this.questionIndex,
      answers: answers ?? this.answers,
      hearts: hearts ?? this.hearts,
      xpEarned: xpEarned ?? this.xpEarned,
      awaitingFeedback: awaitingFeedback ?? this.awaitingFeedback,
      lastAnswerCorrect: clearLastAnswerCorrect
          ? null
          : (lastAnswerCorrect ?? this.lastAnswerCorrect),
      startedAt: startedAt,
    );
  }
}
