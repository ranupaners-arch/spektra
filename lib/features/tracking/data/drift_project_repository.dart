import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/tracking_models.dart';
import 'project_repository.dart';

/// Implementasi lokal (SQLite drift) dari [ProjectRepository].
class DriftProjectRepository implements ProjectRepository {
  DriftProjectRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Project>> watchProjects() {
    final query = _db.select(_db.projectRows).join([
      leftOuterJoin(
        _db.taskRows,
        _db.taskRows.projectId.equalsExp(_db.projectRows.id),
      ),
    ])
      ..orderBy([
        OrderingTerm.asc(_db.projectRows.createdAt),
        OrderingTerm.asc(_db.taskRows.position),
      ]);

    return query.watch().map(_rowsToProjects);
  }

  /// Mengelompokkan baris hasil join (proyek x task) menjadi list proyek.
  List<Project> _rowsToProjects(List<TypedResult> rows) {
    final byId = <int, ({Project project, List<Task> tasks})>{};

    for (final row in rows) {
      final projectRow = row.readTable(_db.projectRows);
      final entry = byId.putIfAbsent(
        projectRow.id,
        () => (project: _toProject(projectRow), tasks: <Task>[]),
      );

      final taskRow = row.readTableOrNull(_db.taskRows);
      if (taskRow != null) {
        entry.tasks.add(_toTask(taskRow));
      }
    }

    return byId.values
        .map((e) => e.project.copyWith(tasks: e.tasks))
        .toList();
  }

  @override
  Future<Project> addProject({
    required String title,
    required ProjectCategory category,
    DateTime? deadline,
  }) async {
    final id = await _db.into(_db.projectRows).insert(
          ProjectRowsCompanion.insert(
            title: title,
            category: category.dbValue,
            deadline: Value<DateTime?>(deadline),
          ),
        );

    return Project(
      id: id,
      title: title,
      category: category,
      deadline: deadline,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteProject(int projectId) async {
    await (_db.delete(_db.projectRows)
          ..where((row) => row.id.equals(projectId)))
        .go();
  }

  @override
  Future<void> setProjectDeadline(int projectId, DateTime? deadline) async {
    await (_db.update(_db.projectRows)
          ..where((row) => row.id.equals(projectId)))
        .write(ProjectRowsCompanion(deadline: Value<DateTime?>(deadline)));
  }

  @override
  Future<void> addTask({
    required int projectId,
    required String name,
    DateTime? deadline,
  }) async {
    final count = await (_db.selectOnly(_db.taskRows)
          ..addColumns([_db.taskRows.id.count()])
          ..where(_db.taskRows.projectId.equals(projectId)))
        .map((row) => row.read(_db.taskRows.id.count())!)
        .getSingle();

    await _db.into(_db.taskRows).insert(
          TaskRowsCompanion.insert(
            projectId: projectId,
            name: name,
            status: TaskStatus.todo.dbValue,
            deadline: Value<DateTime?>(deadline),
            position: Value<int>(count),
          ),
        );
  }

  @override
  Future<void> setTaskStatus(int taskId, TaskStatus status) async {
    await (_db.update(_db.taskRows)
          ..where((row) => row.id.equals(taskId)))
        .write(TaskRowsCompanion(status: Value(status.dbValue)));
  }

  @override
  Future<void> deleteTask(int taskId) async {
    await (_db.delete(_db.taskRows)..where((row) => row.id.equals(taskId)))
        .go();
  }

  Project _toProject(ProjectRecord row) => Project(
        id: row.id,
        title: row.title,
        category: ProjectCategory.fromDb(row.category),
        deadline: row.deadline,
        createdAt: row.createdAt,
      );

  Task _toTask(TaskRecord row) => Task(
        id: row.id,
        projectId: row.projectId,
        name: row.name,
        status: TaskStatus.fromDb(row.status),
        position: row.position,
        deadline: row.deadline,
        createdAt: row.createdAt,
      );
}