import '../domain/tracking_models.dart';

/// Kontrak data fitur tracking.
///
/// Implementasi saat ini: [DriftProjectRepository] (lokal, SQLite).
/// Implementasi berikutnya: Supabase (remote) tinggal tambah class baru
/// dengan interface sama, tanpa menyentuh UI.
abstract class ProjectRepository {
  /// Memantau seluruh project beserta task-nya (urutan task = posisi kanban).
  Stream<List<Project>> watchProjects();

  Future<Project> addProject({
    required String title,
    required ProjectCategory category,
    DateTime? deadline,
  });

  Future<void> deleteProject(int projectId);

  Future<void> setProjectDeadline(int projectId, DateTime? deadline);

  Future<void> addTask({
    required int projectId,
    required String name,
    DateTime? deadline,
  });

  /// Memindahkan task ke status kanban lain.
  Future<void> setTaskStatus(int taskId, TaskStatus status);

  Future<void> deleteTask(int taskId);
}