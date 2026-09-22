/// Model domain fitur tracking. Immutable (copyWith) supaya aman dipakai
/// Riverpod & realtime sync nanti.
library;

enum ProjectCategory {
  kuliah('Kuliah'),
  klien('Klien'),
  pribadi('Pribadi');

  const ProjectCategory(this.label);

  /// Label tampilan, misal untuk badge & judul slide.
  final String label;

  /// Nilai penyimpanan di database.
  int get dbValue => index;

  static ProjectCategory fromDb(int value) => values[value];
}

/// Status kanban untuk task. `done` setara `isDone` di versi lama.
enum TaskStatus {
  todo('To Do'),
  inProgress('In Progress'),
  review('Review'),
  done('Done');

  const TaskStatus(this.label);

  final String label;

  int get dbValue => index;

  static TaskStatus fromDb(int value) => values[value];
}

class Task {
  const Task({
    required this.id,
    required this.projectId,
    required this.name,
    required this.status,
    this.position = 0,
    this.deadline,
    required this.createdAt,
  });

  final int id;
  final int projectId;
  final String name;
  final TaskStatus status;
  final int position;
  final DateTime? deadline;
  final DateTime createdAt;

  bool get isDone => status == TaskStatus.done;

  Task copyWith({
    int? id,
    int? projectId,
    String? name,
    TaskStatus? status,
    int? position,
    DateTime? deadline,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      status: status ?? this.status,
      position: position ?? this.position,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.category,
    this.deadline,
    required this.createdAt,
    this.tasks = const [],
  });

  final int id;
  final String title;
  final ProjectCategory category;
  final DateTime? deadline;
  final DateTime createdAt;
  final List<Task> tasks;

  int get completedCount => tasks.where((t) => t.isDone).length;

  double get progress => tasks.isEmpty ? 0 : completedCount / tasks.length;

  Project copyWith({
    int? id,
    String? title,
    ProjectCategory? category,
    DateTime? deadline,
    DateTime? createdAt,
    List<Task>? tasks,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      tasks: tasks ?? this.tasks,
    );
  }
}