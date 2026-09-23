import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../auth/application/auth_controller.dart';
import '../data/drift_project_repository.dart';
import '../data/project_repository.dart';
import '../data/supabase_project_repository.dart';
import '../domain/tracking_models.dart';

/// Instance database drift (membuka koneksi saat pertama dipakai).
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

/// Repository aktif — dipilih otomatis:
///  * Supabase terkonfigurasi + user login → remote (Postgres + RLS).
///  * Selain itu → lokal (Drift/SQLite). UI tidak tahu bedanya karena
///    keduanya mengimplementasi [ProjectRepository].
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final authEnabled = ref.watch(authModuleEnabledProvider);
  final authed = ref.watch(isAuthenticatedProvider);
  if (authEnabled && authed) {
    return SupabaseProjectRepository();
  }
  return DriftProjectRepository(ref.watch(appDatabaseProvider));
});

/// Stream proyek beserta task-nya, live-update dari database.
final projectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchProjects();
});