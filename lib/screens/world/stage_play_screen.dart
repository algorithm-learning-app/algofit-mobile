import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/world1_stages.dart';
import '../../models/daily_question.dart';
import '../../models/guest_progress.dart';
import '../../models/world_stage.dart';
import '../../services/progress_repository.dart';
import '../../services/stage_service.dart';
import '../../theme/app_colors.dart';
import '../daily/widgets/daily_feedback_view.dart';
import '../daily/widgets/daily_question_view.dart';

class StagePlayScreen extends StatefulWidget {
  const StagePlayScreen({
    super.key,
    required this.repo,
    required this.worldId,
    required this.stageId,
  });

  final ProgressRepository repo;
  final int worldId;
  final String stageId;

  @override
  State<StagePlayScreen> createState() => _StagePlayScreenState();
}

class _StagePlayScreenState extends State<StagePlayScreen> {
  DailyQuestion? _question;
  bool _loading = true;
  bool _showFeedback = false;
  bool _showComplete = false;
  bool? _lastCorrect;

  WorldStage? get _stage {
    for (final stage in world1MapStages) {
      if (stage.id == widget.stageId) return stage;
    }
    return null;
  }

  WorldNodeState get _nodeState {
    final stage = _stage;
    if (stage == null) return WorldNodeState.locked;
    return worldStageNodeState(
      stageOrder: stage.order,
      progressNodes: widget.repo.progress.world1Nodes,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    setState(() => _loading = true);
    final q = await loadStageQuestion(widget.stageId);
    if (mounted) {
      setState(() {
        _question = q;
        _loading = false;
      });
    }
  }

  void _handleSubmit(bool isCorrect) {
    setState(() {
      _lastCorrect = isCorrect;
      _showFeedback = true;
    });
  }

  void _handleFeedbackContinue() {
    if (_lastCorrect != true) {
      setState(() => _showFeedback = false);
      return;
    }

    final stage = _stage;
    if (stage != null && _nodeState != WorldNodeState.locked) {
      widget.repo.completeWorld1Stage(stage.order);
    }

    setState(() {
      _showFeedback = false;
      _showComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stage;
    final title = stage?.title ?? '스테이지';
    final order = stage?.order;
    final locked = _nodeState == WorldNodeState.locked;

    if (locked) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close_rounded),
          ),
          title: Text(order != null ? '1-$order' : title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  '아직 잠긴 스테이지예요',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '앞 스테이지를 먼저 클리어해 주세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('맵으로'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(order != null ? '1-$order · $title' : title),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'World ${widget.worldId} 스테이지',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              height: constraints.maxHeight,
                              child: _buildCardContent(),
                            );
                          },
                        ),
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

  Widget _buildCardContent() {
    if (_loading) {
      return const Center(
        child: Text('불러오는 중…', style: TextStyle(color: AppColors.muted)),
      );
    }

    if (_question == null) {
      return const Center(child: Text('문항을 찾을 수 없어요.'));
    }

    if (_showComplete) {
      return _StageCompleteView(
        stageTitle: _stage?.title ?? '스테이지',
        onMap: () => context.go('/world/${widget.worldId}'),
      );
    }

    if (_showFeedback && _lastCorrect != null) {
      final isCorrect = _lastCorrect!;
      final message = isCorrect
          ? _question!.feedbackCorrect
          : _question!.feedbackWrong;
      return DailyFeedbackView(
        isCorrect: isCorrect,
        message: message,
        onContinue: _handleFeedbackContinue,
      );
    }

    return SingleChildScrollView(
      child: DailyQuestionView(
        key: ValueKey(widget.stageId),
        question: _question!,
        onSubmit: _handleSubmit,
      ),
    );
  }
}

class _StageCompleteView extends StatelessWidget {
  const _StageCompleteView({
    required this.stageTitle,
    required this.onMap,
  });

  final String stageTitle;
  final VoidCallback onMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('🎉', textAlign: TextAlign.center, style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        const Text(
          '스테이지 클리어!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$stageTitle 완료',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, height: 1.45),
        ),
        const SizedBox(height: 16),
        Text(
          '+$stageXpPerQuestion XP',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.xp,
          ),
        ),
        const Spacer(),
        FilledButton(
          onPressed: onMap,
          child: const Text('맵으로 돌아가기'),
        ),
      ],
    );
  }
}
