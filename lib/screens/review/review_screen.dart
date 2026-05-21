import 'package:flutter/material.dart';
import '../../models/daily_question.dart';
import '../../services/daily_service.dart';
import '../../services/progress_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../daily/widgets/daily_feedback_view.dart';
import '../daily/widgets/daily_question_view.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.repo});

  final ProgressRepository repo;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final Map<String, DailyQuestion> _cache = {};
  String? _activeId;
  bool _showFeedback = false;
  bool? _lastCorrect;

  Future<DailyQuestion?> _load(String id) async {
    if (_cache.containsKey(id)) return _cache[id];
    final q = await getQuestionById(id);
    if (q != null) _cache[id] = q;
    return q;
  }

  void _startReview(String id) {
    setState(() {
      _activeId = id;
      _showFeedback = false;
      _lastCorrect = null;
    });
  }

  void _handleSubmit(bool isCorrect) {
    final id = _activeId;
    if (id == null) return;
    widget.repo.recordQuestionOutcome(questionId: id, isCorrect: isCorrect);
    setState(() {
      _lastCorrect = isCorrect;
      _showFeedback = true;
    });
  }

  void _handleContinue() {
    setState(() {
      _activeId = null;
      _showFeedback = false;
      _lastCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repo,
      builder: (context, _) {
        final wrongIds = widget.repo.progress.wrongQuestionIds;

        return Scaffold(
          appBar: AppBar(title: const Text('복습')),
          body: _activeId != null
              ? FutureBuilder<DailyQuestion?>(
                  future: _load(_activeId!),
                  builder: (context, snapshot) {
                    final q = snapshot.data;
                    if (q == null) {
                      return const Center(child: Text('불러오는 중…'));
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _showFeedback && _lastCorrect != null
                              ? DailyFeedbackView(
                                  isCorrect: _lastCorrect!,
                                  message: _lastCorrect!
                                      ? q.feedbackCorrect
                                      : q.feedbackWrong,
                                  explanation: q.explanation,
                                  onContinue: _handleContinue,
                                )
                              : SingleChildScrollView(
                                  child: DailyQuestionView(
                                    key: ValueKey(q.id),
                                    question: q,
                                    onSubmit: _handleSubmit,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                )
              : wrongIds.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('✨', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          '복습할 오답이 없어요',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Daily나 스테이지에서 틀린 문항이 여기에 쌓여요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: wrongIds.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final id = wrongIds[index];
                    return Card(
                      child: ListTile(
                        title: Text(id),
                        subtitle: const Text('다시 풀기'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _startReview(id),
                      ),
                    );
                  },
                ),
          bottomNavigationBar: const AlgofitBottomNavBar(currentIndex: 2),
        );
      },
    );
  }
}
