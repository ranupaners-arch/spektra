import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/drift_project_repository.dart';
import '../data/project_repository.dart';
import '../domain/tracking_models.dart';

/// Instance database drift (membuka koneksi saat pertama dipakai).
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return DriftProjectRepository(ref.watch(appDatabaseProvider));
});

/// Stream proyek beserta task-nya, live-update dari database.
final projectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchProjects();
});