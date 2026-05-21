import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/algorithm_catalog.dart';
import '../../services/algorithm_service.dart';
import '../../services/progress_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';

class AlgorithmCatalogScreen extends StatefulWidget {
  const AlgorithmCatalogScreen({super.key, required this.repo});

  final ProgressRepository repo;

  @override
  State<AlgorithmCatalogScreen> createState() => _AlgorithmCatalogScreenState();
}

class _AlgorithmCatalogScreenState extends State<AlgorithmCatalogScreen> {
  Map<String, double> _progressByTag = {};
  int _loadToken = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    widget.repo.addListener(_loadProgress);
  }

  @override
  void dispose() {
    widget.repo.removeListener(_loadProgress);
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final token = ++_loadToken;
    final cleared = widget.repo.progress.clearedQuestionIds;
    final next = <String, double>{};
    for (final entry in algorithmCatalog) {
      final pool = await questionsForPattern(entry.patternTag);
      if (!mounted || token != _loadToken) return;
      next[entry.patternTag] = progressPercentForPattern(
        patternTag: entry.patternTag,
        clearedQuestionIds: cleared,
        pool: pool,
      );
    }
    if (mounted && token == _loadToken) {
      setState(() => _progressByTag = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repo,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    Text(
                      '알고리즘',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '6가지 패턴 · 진행률은 맞힌 문항 기준',
                      style: TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                    const SizedBox(height: 20),
                    for (final entry in algorithmCatalog)
                      _AlgorithmCard(
                        entry: entry,
                        percent: _progressByTag[entry.patternTag] ?? 0,
                        onTap: () => context.push('/algorithm/${entry.id}'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const AlgofitBottomNavBar(currentIndex: 2),
        );
      },
    );
  }
}

class _AlgorithmCard extends StatelessWidget {
  const _AlgorithmCard({
    required this.entry,
    required this.percent,
    required this.onTap,
  });

  final AlgorithmEntry entry;
  final double percent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pctLabel = '${(percent * 100).round()}%';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(entry.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 6,
                        backgroundColor: AppColors.muted.withValues(
                          alpha: 0.25,
                        ),
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                pctLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
