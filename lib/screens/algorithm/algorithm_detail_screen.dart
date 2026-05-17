import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/algorithm_catalog.dart';
import '../../models/daily_question.dart';
import '../../services/algorithm_service.dart';
import '../../services/progress_repository.dart';
import '../../theme/app_colors.dart';
import '../daily/widgets/daily_feedback_view.dart';
import '../daily/widgets/daily_question_view.dart';

class AlgorithmDetailScreen extends StatefulWidget {
  const AlgorithmDetailScreen({
    super.key,
    required this.repo,
    required this.algorithmId,
  });

  final ProgressRepository repo;
  final String algorithmId;

  @override
  State<AlgorithmDetailScreen> createState() => _AlgorithmDetailScreenState();
}

class _AlgorithmDetailScreenState extends State<AlgorithmDetailScreen> {
  List<DailyQuestion>? _pool;
  int _index = 0;
  bool _showFeedback = false;
  bool? _lastCorrect;

  AlgorithmEntry? get _entry => algorithmById(widget.algorithmId);

  @override
  void initState() {
    super.initState();
    _loadPool();
  }

  Future<void> _loadPool() async {
    final entry = _entry;
    if (entry == null) return;
    final pool = await questionsForPattern(entry.patternTag);
    if (mounted) setState(() => _pool = pool);
  }

  void _handleSubmit(bool isCorrect) {
    final q = _pool![_index];
    widget.repo.recordQuestionOutcome(questionId: q.id, isCorrect: isCorrect);
    setState(() {
      _lastCorrect = isCorrect;
      _showFeedback = true;
    });
  }

  void _handleContinue() {
    if (_lastCorrect != true) {
      setState(() => _showFeedback = false);
      return;
    }
    final nextIndex = _index + 1;
    if (_pool != null && nextIndex < _pool!.length) {
      setState(() {
        _index = nextIndex;
        _showFeedback = false;
        _lastCorrect = null;
      });
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('알고리즘을 찾을 수 없어요.')),
      );
    }

    final pool = _pool;
    final cleared = widget.repo.progress.clearedQuestionIds.toSet();
    final percent = pool == null
        ? 0.0
        : progressPercentForPattern(
            patternTag: entry.patternTag,
            clearedQuestionIds: widget.repo.progress.clearedQuestionIds,
            pool: pool,
          );

    return Scaffold(
      appBar: AppBar(
        title: Text('${entry.icon} ${entry.title}'),
      ),
      body: SafeArea(
        child: pool == null
            ? const Center(child: Text('불러오는 중…'))
            : pool.isEmpty
                ? const Center(child: Text('이 패턴 문항이 아직 없어요.'))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '진행 ${(percent * 100).round()}% · ${_index + 1}/${pool.length}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _showFeedback && _lastCorrect != null
                                  ? DailyFeedbackView(
                                      isCorrect: _lastCorrect!,
                                      message: _lastCorrect!
                                          ? pool[_index].feedbackCorrect
                                          : pool[_index].feedbackWrong,
                                      onContinue: _handleContinue,
                                    )
                                  : DailyQuestionView(
                                      key: ValueKey(pool[_index].id),
                                      question: pool[_index],
                                      onSubmit: _handleSubmit,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final q in pool)
                              Chip(
                                label: Text(
                                  q.id.replaceFirst(RegExp(r'^(pick|blank)_'), ''),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor: cleared.contains(q.id)
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : null,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
