import 'package:go_router/go_router.dart';

import '../features/tracking/presentation/project_detail_screen.dart';
import '../features/tracking/presentation/tracking_screen.dart';

/// Route aplikasi. Nanti ditambah route read-only link untuk klien
/// (Present Mode) di fase kolaborasi.
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TrackingScreen(),
    ),
    GoRoute(
      path: '/project/:projectId',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['projectId'] ?? '');
        return ProjectDetailScreen(projectId: id ?? 0);
      },
    ),
  ],
);