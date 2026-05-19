import 'package:go_router/go_router.dart';

import '../screens/algorithm/algorithm_detail_screen.dart';
import '../screens/algorithm/algorithm_catalog_screen.dart';
import '../screens/daily/daily_challenge_screen.dart';
import '../screens/daily/daily_complete_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../data/stage_questions.dart';
import '../data/world_catalog.dart';
import '../screens/review/review_screen.dart';
import '../screens/world/stage_placeholder_screen.dart';
import '../screens/world/stage_play_screen.dart';
import '../screens/world/world_map_screen.dart';
import '../services/progress_repository.dart';

GoRouter createAppRouter(ProgressRepository repo) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: repo,
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(repo: repo),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfileScreen(repo: repo),
      ),
      GoRoute(
        path: '/review',
        builder: (context, state) => ReviewScreen(repo: repo),
      ),
      GoRoute(
        path: '/algorithm',
        builder: (context, state) => AlgorithmCatalogScreen(repo: repo),
        routes: [
          GoRoute(
            path: ':algorithmId',
            builder: (context, state) {
              final algorithmId = state.pathParameters['algorithmId'] ?? '';
              return AlgorithmDetailScreen(
                repo: repo,
                algorithmId: algorithmId,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/world/:worldId',
        redirect: (context, state) {
          final worldId = int.tryParse(state.pathParameters['worldId'] ?? '');
          if (worldId == null || !isWorldSupported(worldId)) {
            return '/home';
          }
          return null;
        },
        builder: (context, state) {
          final worldId =
              int.tryParse(state.pathParameters['worldId'] ?? '') ?? 1;
          return WorldMapScreen(repo: repo, worldId: worldId);
        },
        routes: [
          GoRoute(
            path: 'stage/:stageId',
            redirect: (context, state) {
              final worldId =
                  int.tryParse(state.pathParameters['worldId'] ?? '') ?? 1;
              final stageId = state.pathParameters['stageId'] ?? '';
              if (!isWorldSupported(worldId)) return '/home';
              if (!hasStageContent(stageId)) {
                return '/world/$worldId';
              }
              return null;
            },
            builder: (context, state) {
              final worldId =
                  int.tryParse(state.pathParameters['worldId'] ?? '') ?? 1;
              final stageId = state.pathParameters['stageId'] ?? '';
              if (hasStageContent(stageId)) {
                return StagePlayScreen(
                  repo: repo,
                  worldId: worldId,
                  stageId: stageId,
                );
              }
              return StagePlaceholderScreen(worldId: worldId, stageId: stageId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/daily',
        redirect: (context, state) {
          if (repo.progress.todayDailyCompleted) {
            return '/daily/complete';
          }
          final step = repo.dailyResumeStep();
          return '/daily/$step';
        },
      ),
      GoRoute(
        path: '/daily/complete',
        builder: (context, state) {
          final extra = state.extra as DailyCompleteArgs?;
          return DailyCompleteScreen(
            repo: repo,
            allCorrect: extra?.allCorrect ?? repo.progress.todayAllCorrect,
            xpEarned: extra?.xpEarned ?? (repo.progress.dailyProgress * 10),
          );
        },
      ),
      GoRoute(
        path: '/daily/:step',
        redirect: (context, state) {
          if (!repo.progress.todayDailyCompleted) return null;
          final segments = state.uri.pathSegments;
          final isFeedback =
              segments.length >= 3 && segments.last == 'feedback';
          if (!isFeedback) return '/daily/complete';
          return null;
        },
        builder: (context, state) {
          final stepParam = state.pathParameters['step']!;
          if (stepParam == 'complete') {
            return DailyCompleteScreen(repo: repo);
          }
          final step = int.tryParse(stepParam);
          final isFeedback =
              state.uri.pathSegments.length >= 3 &&
              state.uri.pathSegments.last == 'feedback';
          return DailyChallengeScreen(
            repo: repo,
            step: step,
            isFeedback: isFeedback,
          );
        },
        routes: [
          GoRoute(
            path: 'feedback',
            builder: (context, state) {
              final step = int.tryParse(state.pathParameters['step']!) ?? 1;
              return DailyChallengeScreen(
                repo: repo,
                step: step,
                isFeedback: true,
              );
            },
          ),
        ],
      ),
    ],
  );
}

class DailyCompleteArgs {
  const DailyCompleteArgs({required this.allCorrect, required this.xpEarned});

  final bool allCorrect;
  final int xpEarned;
}
