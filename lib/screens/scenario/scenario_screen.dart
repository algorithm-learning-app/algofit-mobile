import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/scenario_question.dart';
import '../../services/progress_repository.dart';
import '../../services/scenario_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/choice_tile.dart';
import '../../widgets/mascot.dart';
import '../../widgets/stem_text.dart';

/// 실전 시나리오 모드: 긴 도메인 지문을 읽고 알맞은 알고리즘 패턴을 고른다.
/// 한 세션 [scenarioSessionSize]문항, 하트 미소모, 정답 시 XP.
class ScenarioScreen extends StatefulWidget {
  const ScenarioScreen({super.key, required this.repo});

  final ProgressRepository repo;

  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  List<ScenarioQuestion>? _session;
  int _index = 0;
  String? _selected;
  bool _showFeedback = false;
  bool _lastCorrect = false;
  int _correctCount = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await loadScenarios();
    if (!mounted) return;
    setState(() => _session = buildScenarioSession(all));
  }

  /// 호출 계약: _buildBody가 로딩(_session==null)/빈(isEmpty)/완료(_finished)를
  /// 먼저 가드한 뒤 _buildQuestion·_buildFeedback에서만 호출되므로
  /// _session은 non-null이고 _index는 범위 내다.
  ScenarioQuestion get _current => _session![_index];

  void _submit() {
    if (_selected == null || _showFeedback) return;
    final correct = _current.isCorrectChoice(_selected!);
    widget.repo.recordScenarioAnswer(isCorrect: correct);
    setState(() {
      _showFeedback = true;
      _lastCorrect = correct;
      if (correct) _correctCount++;
    });
  }

  void _next() {
    if (_index + 1 >= _session!.length) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _showFeedback = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final session = _session;
    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (session.isEmpty) {
      return _EmptyState(onBack: () => context.go('/home'));
    }
    if (_finished) {
      return _ScenarioComplete(
        correct: _correctCount,
        total: session.length,
        onHome: () => context.go('/home'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          step: _index + 1,
          total: session.length,
          onClose: () => context.go('/home'),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: _showFeedback ? _buildFeedback() : _buildQuestion(),
          ),
        ),
        const SizedBox(height: 8),
        if (_showFeedback)
          FilledButton(
            onPressed: _next,
            child: Text(_index + 1 >= session.length ? '결과 보기' : '다음'),
          )
        else
          FilledButton(
            onPressed: _selected == null ? null : _submit,
            child: const Text('확인'),
          ),
      ],
    );
  }

  Widget _buildQuestion() {
    final q = _current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CategoryChip(category: q.scenarioCategory),
        const SizedBox(height: 12),
        StemText(
          text: q.stem,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 8),
        const Text(
          '어떤 패턴으로 풀까요?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 12),
        for (final entry in q.patternChoices.asMap().entries)
          Padding(
            key: ValueKey('scenario-choice-${entry.key}'),
            padding: const EdgeInsets.only(bottom: 8),
            child: ChoiceTile(
              label: entry.value.label,
              selected: _selected == entry.value.id,
              onTap: () => setState(() => _selected = entry.value.id),
            ),
          ),
      ],
    );
  }

  Widget _buildFeedback() {
    final q = _current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Mascot(
            _lastCorrect ? MascotMood.happy : MascotMood.sad,
            size: 96,
            animate: true,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _lastCorrect ? '정답!' : '아쉬워요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.displayFontFamily,
            fontSize: 24,
            color: _lastCorrect
                ? AppColors.primary
                : const Color(0xFFF87171),
          ),
        ),
        if (_lastCorrect) ...[
          const SizedBox(height: 8),
          Text(
            '+$scenarioXpPerQuestion XP',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.xp,
            ),
          ),
        ],
        const SizedBox(height: 16),
        StemText(
          text: q.explanation,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.step,
    required this.total,
    required this.onClose,
  });

  final int step;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded),
          color: AppColors.muted,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            label: '진행 $step/$total',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: step / total,
                minHeight: 8,
                backgroundColor: AppColors.muted.withValues(alpha: 0.25),
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$step / $total',
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '실전 · ${scenarioCategoryLabel(category)}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _ScenarioComplete extends StatelessWidget {
  const _ScenarioComplete({
    required this.correct,
    required this.total,
    required this.onHome,
  });

  final int correct;
  final int total;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final allCorrect = correct == total;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: Mascot(MascotMood.happy, size: 132, animate: true)),
        const SizedBox(height: 16),
        Text(
          allCorrect ? '시나리오 정복!' : '시나리오 완료',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          '$total문제 중 $correct문제 정답',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppColors.muted),
        ),
        const SizedBox(height: 6),
        Text(
          '+${correct * scenarioXpPerQuestion} XP',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.xp,
          ),
        ),
        const SizedBox(height: 32),
        FilledButton(onPressed: onHome, child: const Text('홈으로')),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '아직 시나리오가 없어요.',
          style: TextStyle(fontSize: 16, color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: onBack, child: const Text('홈으로')),
      ],
    );
  }
}

/// 시나리오 카테고리 → 한국어 라벨. ([docs/12-real-world-scenarios.md] taxonomy)
String scenarioCategoryLabel(String category) {
  switch (category) {
    case 'logistics':
      return '물류·경로';
    case 'matching':
      return '매칭·추천';
    case 'scheduling':
      return '스케줄링';
    case 'search_filter':
      return '검색·필터';
    case 'aggregation':
      return '집계·통계';
    case 'limits_security':
      return '제한·보안';
    case 'inventory':
      return '재고·잔여';
    case 'navigation':
      return '탐색·지도';
    default:
      return '시나리오';
  }
}
