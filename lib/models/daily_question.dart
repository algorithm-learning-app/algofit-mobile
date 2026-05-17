const defaultFeedbackCorrect = '정답이에요!';
const defaultFeedbackWrong = '아쉬워요. 다시 한번 생각해보세요.';

class DailyChoice {
  const DailyChoice({required this.id, required this.label});

  factory DailyChoice.fromJson(Map<String, dynamic> json) {
    return DailyChoice(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }

  final String id;
  final String label;
}

class BlankSlot {
  const BlankSlot({
    required this.id,
    required this.correctAnswers,
    required this.choices,
  });

  factory BlankSlot.fromJson(Map<String, dynamic> json) {
    return BlankSlot(
      id: json['id'] as String,
      correctAnswers: (json['correctAnswers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      choices:
          (json['choices'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  final String id;
  final List<String> correctAnswers;
  final List<String> choices;
}

sealed class DailyQuestion {
  const DailyQuestion({
    required this.id,
    required this.stem,
    required this.explanation,
    required this.feedbackCorrect,
    required this.feedbackWrong,
  });

  final String id;
  final String stem;
  final String explanation;
  final String feedbackCorrect;
  final String feedbackWrong;

  factory DailyQuestion.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    if (type == 'pick') {
      return PickQuestion.fromJson(json);
    }
    return BlankQuestion.fromJson(json);
  }
}

class PickQuestion extends DailyQuestion {
  const PickQuestion({
    required super.id,
    required super.stem,
    required super.explanation,
    required super.feedbackCorrect,
    required super.feedbackWrong,
    required this.choices,
    required this.correctChoiceId,
    this.tags = const [],
  });

  factory PickQuestion.fromJson(Map<String, dynamic> json) {
    return PickQuestion(
      id: json['id'] as String,
      stem: json['stem'] as String,
      explanation: json['explanation'] as String,
      feedbackCorrect:
          json['feedbackCorrect'] as String? ?? defaultFeedbackCorrect,
      feedbackWrong: json['feedbackWrong'] as String? ?? defaultFeedbackWrong,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => DailyChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctChoiceId: json['correctChoiceId'] as String,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  final List<DailyChoice> choices;
  final String correctChoiceId;
  final List<String> tags;
}

class BlankQuestion extends DailyQuestion {
  const BlankQuestion({
    required super.id,
    required super.stem,
    required super.explanation,
    required super.feedbackCorrect,
    required super.feedbackWrong,
    required this.codeTemplate,
    required this.blanks,
    this.tags = const [],
  });

  factory BlankQuestion.fromJson(Map<String, dynamic> json) {
    return BlankQuestion(
      id: json['id'] as String,
      stem: json['stem'] as String,
      explanation: json['explanation'] as String,
      feedbackCorrect:
          json['feedbackCorrect'] as String? ?? defaultFeedbackCorrect,
      feedbackWrong: json['feedbackWrong'] as String? ?? defaultFeedbackWrong,
      codeTemplate: json['codeTemplate'] as String,
      blanks: (json['blanks'] as List<dynamic>)
          .map((e) => BlankSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  final String codeTemplate;
  final List<BlankSlot> blanks;
  final List<String> tags;
}

class DailyPack {
  const DailyPack({
    required this.id,
    required this.title,
    required this.questions,
  });

  factory DailyPack.fromJson(Map<String, dynamic> json) {
    return DailyPack(
      id: json['id'] as String,
      title: json['title'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => DailyQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String id;
  final String title;
  final List<DailyQuestion> questions;
}
