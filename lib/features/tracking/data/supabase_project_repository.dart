import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/tracking_models.dart';
import 'project_repository.dart';

/// Implementasi remote (Supabase Postgres + RLS) dari [ProjectRepository].
///
/// Setiap query berjalan atas nama user yang login (session Bearer dari
/// `Supabase.instance.client.auth`). PostgREST + RLS memastikan user hanya
/// melihat/memodifikasi baris miliknya sendiri.
///
/// Live update lewat Realtime Channel (`postgres_changes`) + refetch; embedded
/// `tasks(*)` di-select penuh (`.stream()` bawaan tak mendukung embedded
/// resource), sehingga hapus task tetap terlihat.
class SupabaseProjectRepository implements ProjectRepository {
  SupabaseProjectRepository();

  SupabaseClient get _client => Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('Belum login — butuh sesi Supabase untuk akses data.');
    }
    return id;
  }

  @override
  Stream<List<Project>> watchProjects() {
    final client = _client;
    final controller = StreamController<List<Project>>();

    Future<void> refresh() async {
      try {
        final rows = await client
            .from('projects')
            .select('*, tasks(*)')
            .order('created_at');
        final projects = [
          for (final row in rows) _projectFromRow(row),
        ]..sort((a, b) {
            final byTime = a.createdAt.compareTo(b.createdAt);
            return byTime != 0 ? byTime : a.id.compareTo(b.id);
          });
        if (!controller.isClosed) controller.add(projects);
      } catch (_) {
        // Biarkan refresh berikutnya (realtime/periodik) yang memperbaiki.
      }
    }

    final channel = client
        .realtime
        .channel('spektra-projects')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'projects',
          callback: (_) => refresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          callback: (_) => refresh(),
        );

    refresh();
    final timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => refresh(),
    );
    channel.subscribe();

    controller.onCancel = () {
      timer.cancel();
      client.removeChannel(channel);
    };

    return controller.stream;
  }

  @override
  Future<Project> addProject({
    required String title,
    required ProjectCategory category,
    DateTime? deadline,
  }) async {
    final row = await _client
        .from('projects')
        .insert({
          'title': title,
          'category': category.dbValue,
          'deadline': _encodeDeadline(deadline),
          'owner_id': _userId,
        })
        .select()
        .single();
    return _projectFromRow(row);
  }

  @override
  Future<void> deleteProject(int projectId) async {
    await _client.from('projects').delete().eq('id', projectId);
  }

  @override
  Future<void> setProjectDeadline(int projectId, DateTime? deadline) async {
    await _client
        .from('projects')
        .update({'deadline': _encodeDeadline(deadline)})
        .eq('id', projectId);
  }

  @override
  Future<void> addTask({
    required int projectId,
    required String name,
    DateTime? deadline,
    TaskStatus status = TaskStatus.todo,
    int? position,
  }) async {
    var pos = position;
    if (pos == null) {
      final existing = await _client
          .from('tasks')
          .select('id')
          .eq('project_id', projectId)
          .eq('status', status.dbValue);
      pos = existing.length;
    }
    await _client.from('tasks').insert({
      'project_id': projectId,
      'name': name,
      'status': status.dbValue,
      'position': pos,
      'deadline': _encodeDeadline(deadline),
    });
  }

  @override
  Future<void> setTaskStatus(int taskId, TaskStatus status) async {
    await _client
        .from('tasks')
        .update({'status': status.dbValue})
        .eq('id', taskId);
  }

  @override
  Future<void> moveTask({
    required int taskId,
    required TaskStatus status,
    required int position,
  }) async {
    final client = _client;

    final current =
        (await client.from('tasks').select().eq('id', taskId).single());
    final projectId = (current['project_id'] as num).toInt();
    final oldStatus = TaskStatus.fromDb((current['status'] as num).toInt());

    final all = await client.from('tasks').select().eq('project_id', projectId);

    final columns = <TaskStatus, List<Map<String, dynamic>>>{
      for (final s in TaskStatus.values) s: <Map<String, dynamic>>[],
    };
    for (final row in all) {
      if ((row['id'] as num).toInt() == taskId) continue;
      columns[TaskStatus.fromDb((row['status'] as num).toInt())]!
          .add(row);
    }
    for (final list in columns.values) {
      list.sort((a, b) {
        final byPos = (a['position'] as num).toInt().compareTo(
            (b['position'] as num).toInt());
        return byPos != 0
            ? byPos
            : (a['id'] as num).toInt().compareTo((b['id'] as num).toInt());
      });
    }

    final target = columns[status]!;
    final index = position.clamp(0, target.length);
    target.insert(index, current);

    Future<void> assignRow(
      Map<String, dynamic> row,
      int newPosition, {
      TaskStatus? newStatus,
    }) async {
      final curStatus =
          TaskStatus.fromDb((row['status'] as num).toInt());
      final curPosition = (row['position'] as num).toInt();
      if (curPosition == newPosition &&
          (newStatus == null || curStatus == newStatus)) {
        return;
      }
      final patch = <String, dynamic>{'position': newPosition};
      if (newStatus != null) patch['status'] = newStatus.dbValue;
      await client.from('tasks').update(patch).eq('id', row['id'] as int);
    }

    final oldColumn = columns[oldStatus]!;
    if (oldStatus == status) {
      for (var i = 0; i < target.length; i++) {
        await assignRow(target[i], i);
      }
    } else {
      for (var i = 0; i < oldColumn.length; i++) {
        await assignRow(oldColumn[i], i);
      }
      for (var i = 0; i < target.length; i++) {
        await assignRow(target[i], i,
            newStatus: (target[i]['id'] as num).toInt() == taskId
                ? status
                : null);
      }
    }
  }

  @override
  Future<void> setTaskDeadline(int taskId, DateTime? deadline) async {
    await _client
        .from('tasks')
        .update({'deadline': _encodeDeadline(deadline)})
        .eq('id', taskId);
  }

  @override
  Future<void> renameTask(int taskId, String name) async {
    await _client.from('tasks').update({'name': name}).eq('id', taskId);
  }

  @override
  Future<void> deleteTask(int taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }

  String? _encodeDeadline(DateTime? deadline) =>
      deadline?.toUtc().toIso8601String();

  Project _projectFromRow(Map<String, dynamic> row) {
    final tasks = [
      for (final t in row['tasks'] as List<dynamic>? ?? const [])
        _taskFromRow(t as Map<String, dynamic>),
    ]..sort((a, b) {
        final byPos = a.position.compareTo(b.position);
        return byPos != 0 ? byPos : a.id.compareTo(b.id);
      });

    return Project(
      id: (row['id'] as num).toInt(),
      title: row['title'] as String,
      category: ProjectCategory.fromDb((row['category'] as num).toInt()),
      deadline: _parseTs(row['deadline']),
      createdAt: _parseTs(row['created_at']) ?? DateTime.now(),
      tasks: tasks,
    );
  }

  Task _taskFromRow(Map<String, dynamic> row) => Task(
        id: (row['id'] as num).toInt(),
        projectId: (row['project_id'] as num).toInt(),
        name: row['name'] as String,
        status: TaskStatus.fromDb((row['status'] as num).toInt()),
        position: (row['position'] as num?)?.toInt() ?? 0,
        deadline: _parseTs(row['deadline']),
        createdAt: _parseTs(row['created_at']) ?? DateTime.now(),
      );

  /// PostgREST mengirim `timestamptz` sebagai string ISO 8601 (atau sudah
  /// DateTime bila decoded oleh paket). Normalisasi ke waktu lokal.
  DateTime? _parseTs(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    return DateTime.tryParse(value.toString())?.toLocal();
  }
}