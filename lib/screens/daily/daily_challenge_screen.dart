import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/daily_question.dart';
import '../../models/daily_session.dart';
import '../../router/app_router.dart';
import '../../services/daily_service.dart';
import '../../services/progress_repository.dart';
import '../../theme/app_colors.dart';
import 'widgets/daily_feedback_view.dart';
import 'widgets/daily_question_view.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({
    super.key,
    required this.repo,
    required this.step,
    this.isFeedback = false,
  });

  final ProgressRepository repo;
  final int? step;
  final bool isFeedback;

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  DailyQuestion? _question;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initSession();
    _loadQuestion();
  }

  @override
  void didUpdateWidget(covariant DailyChallengeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step || oldWidget.isFeedback != widget.isFeedback) {
      _loadQuestion();
    }
  }

  void _initSession() {
    if (widget.repo.progress.todayDailyCompleted) return;
    if (widget.repo.dailySession == null) {
      widget.repo.startDailySession();
    }
  }

  Future<void> _loadQuestion() async {
    final step = widget.step;
    if (step == null || step < 1 || step > dailyTotal) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final q = await getDailyQuestion(step - 1);
    if (mounted) {
      setState(() {
        _question = q;
        _loading = false;
      });
    }
  }

  DailySession? get _session => widget.repo.dailySession;

  void _handleSubmit(bool isCorrect) {
    final session = _session;
    final step = widget.step;
    if (session == null || step == null) return;

    widget.repo.recordDailyAnswer(
      session,
      isCorrect,
      questionId: _question?.id,
    );
    if (mounted) {
      context.go('/daily/$step/feedback');
    }
  }

  void _handleFeedbackContinue() {
    final session = _session;
    if (session == null) return;

    if (session.answers.length >= dailyTotal) {
      final allCorrect = session.answers.every((a) => a);
      widget.repo.completeDailyChallenge(session);
      if (mounted) {
        context.go(
          '/daily/complete',
          extra: DailyCompleteArgs(
            allCorrect: allCorrect,
            xpEarned: session.xpEarned,
          ),
        );
      }
      return;
    }

    final next = widget.repo.advanceAfterFeedback(session);
    if (mounted) {
      context.go('/daily/${next.questionIndex + 1}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.repo.progress.todayDailyCompleted && !widget.isFeedback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/daily/complete');
      });
    }

    final step = widget.step;
    final session = _session;

    if (step == null || step < 1 || step > dailyTotal) {
      return const Scaffold(
        body: Center(child: Text('잘못된 경로예요.')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DailyTopBar(
                    hearts: session?.hearts ?? 5,
                    onBack: () => context.go('/home'),
                  ),
                  const SizedBox(height: 16),
                  _ProgressDots(
                    step: step,
                    answeredCount: session?.answers.length ?? 0,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildCardContent(session),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(DailySession? session) {
    if (_loading) {
      return const Center(
        child: Text('불러오는 중…', style: TextStyle(color: AppColors.muted)),
      );
    }

    if (_question == null) {
      return const Center(child: Text('문항을 찾을 수 없어요.'));
    }

    if (widget.isFeedback && session != null && session.awaitingFeedback) {
      final isCorrect = session.lastAnswerCorrect == true;
      final message = isCorrect
          ? _question!.feedbackCorrect
          : _question!.feedbackWrong;
      return DailyFeedbackView(
        isCorrect: isCorrect,
        message: message,
        onContinue: _handleFeedbackContinue,
      );
    }

    return DailyQuestionView(
      key: ValueKey(widget.step),
      question: _question!,
      onSubmit: _handleSubmit,
    );
  }
}

class _DailyTopBar extends StatelessWidget {
  const _DailyTopBar({required this.hearts, required this.onBack});

  final int hearts;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: onBack,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.muted,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            '← 홈',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const Spacer(),
        Semantics(
          label: '하트 $hearts개',
          child: Row(
            children: List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '❤️',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(
                      alpha: i < hearts ? 1 : 0.35,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.step, required this.answeredCount});

  final int step;
  final int answeredCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '진행 $step/$dailyTotal',
      child: Row(
        children: List.generate(dailyTotal, (i) {
          final done = i < answeredCount;
          final current = i == step - 1;
          return Padding(
            padding: EdgeInsets.only(right: i < dailyTotal - 1 ? 8 : 0),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || current
                    ? AppColors.primary
                    : AppColors.muted.withValues(alpha: 0.35),
                boxShadow: current
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}
