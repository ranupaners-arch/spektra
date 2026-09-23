import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation_mode/presentation/presentation_screen.dart';
import '../../quiz_mode/presentation/quiz_screen.dart';
import '../application/deadline_utils.dart';
import '../application/project_colors.dart';
import '../application/task_status_colors.dart';
import '../application/tracking_providers.dart';
import '../domain/tracking_models.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return switch (projectsAsync) {
      AsyncData(:final value) when _find(value) == null =>
        const _NotFoundState(),
      AsyncData(:final value) => _DetailBody(project: _find(value)!),
      AsyncError() => const _DetailError(),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }

  Project? _find(List<Project> projects) {
    for (final project in projects) {
      if (project.id == projectId) return project;
    }
    return null;
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = countDeadlineStates(project.tasks);

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: project.color,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == 'delete') _confirmDeleteProject(context, ref);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus Proyek'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(context, ref),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeButton(
                        context,
                        icon: Icons.present_to_all,
                        label: 'Presentasi',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PresentationScreen(project: project),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModeButton(
                        context,
                        icon: Icons.quiz,
                        label: 'Buat Kuiz',
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(project: project),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDeadlineBanners(context, counts),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kanban Board',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          _showAddTaskDialog(context, ref, projectId: project.id),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Tugas'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _KanbanBoard(
project: project,
                  onAddTask: (status) => _showAddTaskDialog(
                    context,
                    ref,
                    projectId: project.id,
                    initialColumn: status,
                  ),
              onEditTask: (task) => _showEditTaskDialog(context, ref, task),
              onEditDeadline: (task) => _showTaskDeadlineSheet(context, ref, task),
              onMoveTask: (task, status, position) =>
                  ref.read(projectRepositoryProvider).moveTask(
                        taskId: task.id,
                        status: status,
                        position: position,
                      ),
              onDeleteTask: (task) =>
                  ref.read(projectRepositoryProvider).deleteTask(task.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: project.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category, color: project.color),
              const SizedBox(width: 8),
              Text(
                project.category.label,
                style: TextStyle(
                  color: project.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showProjectDeadlineSheet(
                  context,
                  ref,
                  project.id,
                  initial: project.deadline,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event, color: project.color, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        project.deadline == null
                            ? 'Atur tenggat'
                            : formatDeadline(project.deadline!),
                        style: TextStyle(
                          color: project.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Progress Keseluruhan',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: project.progress,
              backgroundColor: Colors.grey[300],
              color: project.color,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(project.progress * 100).toInt()}% Selesai',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDeadlineBanners(
    BuildContext context,
    Map<DeadlineState, int> counts,
  ) {
    final banners = <Widget>[
      if (counts[DeadlineState.overdue]! > 0)
        _DeadlineBanner(
          icon: Icons.error_outline,
          color: Colors.red,
          text: '${counts[DeadlineState.overdue]} tugas melewati tenggat',
        ),
      if (counts[DeadlineState.dueWithinOneDay]! > 0)
        _DeadlineBanner(
          icon: Icons.alarm,
          color: Colors.orange,
          text: '${counts[DeadlineState.dueWithinOneDay]} tugas '
              'jatuh tempo besok / hari ini',
        ),
      if (counts[DeadlineState.dueWithinThreeDays]! > 0)
        _DeadlineBanner(
          icon: Icons.notifications_active,
          color: Colors.amber,
          text: '${counts[DeadlineState.dueWithinThreeDays]} tugas '
              'jatuh tempo dalam 3 hari',
        ),
    ];

    if (banners.isEmpty) return const SizedBox.shrink();
    return Column(children: banners);
  }

  void _confirmDeleteProject(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Proyek?'),
        content: Text(
          'Seluruh tugas di dalam "${project.title}" ikut terhapus. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref
                  .read(projectRepositoryProvider)
                  .deleteProject(project.id);
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/');
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _KanbanBoard extends StatelessWidget {
  const _KanbanBoard({
    required this.project,
    required this.onAddTask,
    required this.onEditTask,
    required this.onEditDeadline,
    required this.onMoveTask,
    required this.onDeleteTask,
  });

  final Project project;
  final void Function(TaskStatus status) onAddTask;
  final void Function(Task task) onEditTask;
  final void Function(Task task) onEditDeadline;
  final void Function(Task task, TaskStatus status, int position) onMoveTask;
  final void Function(Task task) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final status in TaskStatus.values) ...[
            _KanbanColumn(
              status: status,
              tasks: project.tasks
                  .where((t) => t.status == status)
                  .toList(),
              onAddTask: () => onAddTask(status),
              onEditTask: onEditTask,
              onEditDeadline: onEditDeadline,
              onMoveTask: onMoveTask,
              onDeleteTask: onDeleteTask,
            ),
            if (status != TaskStatus.done) const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({
    required this.status,
    required this.tasks,
    required this.onAddTask,
    required this.onEditTask,
    required this.onEditDeadline,
    required this.onMoveTask,
    required this.onDeleteTask,
  });

  final TaskStatus status;
  final List<Task> tasks;
  final VoidCallback onAddTask;
  final void Function(Task task) onEditTask;
  final void Function(Task task) onEditDeadline;
  final void Function(Task task, TaskStatus status, int position) onMoveTask;
  final void Function(Task task) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final accent = status.color;

    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final task = details.data;
        if (task.status != status) {
          onMoveTask(task, status, tasks.length);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          width: 300,
          decoration: BoxDecoration(
            color: isHovering
                ? accent.withValues(alpha: 0.08)
                : accent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering ? accent : accent.withValues(alpha: 0.25),
              width: isHovering ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onAddTask,
                      icon: const Icon(Icons.add),
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Tambah ke ${status.label}',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: tasks.isEmpty
                    ? _EmptyColumnDropHint(
                        hovered: isHovering,
                        accent: accent,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TaskCard(
                              task: task,
                              accent: accent,
                              isFirst: index == 0,
                              isLast: index == tasks.length - 1,
                              onTap: () => onEditTask(task),
                              onUp: index == 0
                                  ? null
                                  : () => onMoveTask(task, status, index - 1),
                              onDown: index == tasks.length - 1
                                  ? null
                                  : () => onMoveTask(task, status, index + 1),
                              onMarkDone: status == TaskStatus.done
                                  ? null
                                  : () => onMoveTask(
                                      task,
                                      TaskStatus.done,
                                      tasks.length,
                                    ),
                              onEditDeadline: () => onEditDeadline(task),
                              onDelete: () => onDeleteTask(task),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.accent,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.onUp,
    required this.onDown,
    required this.onMarkDone,
    required this.onEditDeadline,
    required this.onDelete,
  });

  final Task task;
  final Color accent;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onMarkDone;
  final VoidCallback onEditDeadline;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final deadline = task.deadline;
    final state = deadlineState(deadline);
    final deadlineColor = switch (state) {
      DeadlineState.overdue => Colors.red,
      DeadlineState.dueWithinOneDay => Colors.orange,
      DeadlineState.dueWithinThreeDays => Colors.amber.shade700,
      DeadlineState.upcoming || DeadlineState.none => Colors.grey,
    };

    return LongPressDraggable<Task>(
      data: task,
      delay: const Duration(milliseconds: 250),
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(10),
        child: Opacity(opacity: 0.9, child: _TaskCardContent(
          task: task,
          accent: accent,
          isHovering: false,
        )),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _TaskCardContent(
          task: task,
          accent: accent,
          isHovering: false,
        ),
      ),
      child: _TaskCardContent(
        task: task,
        accent: accent,
        isHovering: false,
        onTap: onTap,
        onUp: onUp,
        onDown: onDown,
        onMarkDone: onMarkDone,
        onEditDeadline: onEditDeadline,
        onDelete: onDelete,
        deadlineColor: deadlineColor,
      ),
    );
  }
}

class _TaskCardContent extends StatelessWidget {
  const _TaskCardContent({
    required this.task,
    required this.accent,
    required this.isHovering,
    this.onTap,
    this.onUp,
    this.onDown,
    this.onMarkDone,
    this.onEditDeadline,
    this.onDelete,
    this.deadlineColor,
  });

  final Task task;
  final Color accent;
  final bool isHovering;
  final VoidCallback? onTap;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onMarkDone;
  final VoidCallback? onEditDeadline;
  final VoidCallback? onDelete;
  final Color? deadlineColor;

  @override
  Widget build(BuildContext context) {
    final deadline = task.deadline;
    final col = deadlineColor ?? Colors.grey;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isHovering ? accent : accent.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration:
                      task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                  color:
                      task.status == TaskStatus.done ? Colors.grey : Colors.black87,
                ),
              ),
              if (deadline != null) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event, size: 14, color: col),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        deadlineRelativeLabel(deadline),
                        style: TextStyle(
                          fontSize: 12,
                          color: col,
                          fontWeight:
                              stateWeight(deadlineState(deadline)),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Wrap(
                spacing: 2,
                runSpacing: 2,
                children: [
                  if (onMarkDone != null)
                    IconButton(
                      onPressed: onMarkDone,
                      icon: Icon(
                        Icons.check_circle_outline,
                        color: Colors.green.shade700,
                      ),
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      tooltip: 'Tandai Selesai',
                    ),
                  IconButton(
                    onPressed: onEditDeadline,
                    icon: const Icon(Icons.event, size: 18, color: Colors.grey),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    tooltip: 'Atur tenggat',
                  ),
                  IconButton(
                    onPressed: onUp,
                    icon: const Icon(Icons.arrow_upward,
                        size: 18, color: Colors.grey),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    tooltip: 'Naik',
                  ),
                  IconButton(
                    onPressed: onDown,
                    icon: const Icon(Icons.arrow_downward,
                        size: 18, color: Colors.grey),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    tooltip: 'Turun',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.redAccent),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  FontWeight stateWeight(DeadlineState state) => switch (state) {
        DeadlineState.overdue => FontWeight.bold,
        DeadlineState.dueWithinOneDay ||
        DeadlineState.dueWithinThreeDays =>
          FontWeight.w600,
        _ => FontWeight.normal,
      };
}

class _EmptyColumnDropHint extends StatelessWidget {
  const _EmptyColumnDropHint({required this.hovered, required this.accent});

  final bool hovered;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.drag_indicator,
              color: hovered ? accent : accent.withValues(alpha: 0.4),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              hovered ? 'Lepaskan di sini' : 'Kosong',
              style: TextStyle(
                color: hovered ? accent : Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeadlineBanner extends StatelessWidget {
  const _DeadlineBanner({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Dialog & sheet ----

Future<void> _showProjectDeadlineSheet(
  BuildContext context,
  WidgetRef ref,
  int projectId, {
  DateTime? initial,
}) {
  return _showDeadlineSheet(
    context,
    initial: initial,
    onSelect: (deadline) =>
        ref.read(projectRepositoryProvider).setProjectDeadline(projectId, deadline),
  );
}

Future<void> _showTaskDeadlineSheet(
  BuildContext context,
  WidgetRef ref,
  Task task,
) {
  return _showDeadlineSheet(
    context,
    initial: task.deadline,
    onSelect: (deadline) =>
        ref.read(projectRepositoryProvider).setTaskDeadline(task.id, deadline),
  );
}

/// Bottom sheet untuk memilih / menghapus / tidak mengubah tenggat.
Future<void> _showDeadlineSheet(
  BuildContext context, {
  required DateTime? initial,
  required Future<void> Function(DateTime? deadline) onSelect,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Pilih Tanggal'),
            subtitle: initial == null
                ? const Text('Tentukan tenggat')
                : Text('Saat ini: ${formatDeadline(initial)}'),
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: initial ?? DateTime(now.year, now.month, now.day + 1),
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 5),
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              if (picked != null) await onSelect(picked);
            },
          ),
          if (initial != null)
            ListTile(
              leading: const Icon(Icons.event_busy, color: Colors.red),
              title: const Text('Hapus Tenggat'),
              onTap: () async {
                Navigator.pop(context);
                await onSelect(null);
              },
            ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Batal'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}

void _showAddTaskDialog(
  BuildContext context,
  WidgetRef ref, {
  required int projectId,
  TaskStatus initialColumn = TaskStatus.todo,
}) {
  final controller = TextEditingController();
  DateTime? deadline;
  var status = initialColumn;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Tambah Tugas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Tugas',
                  hintText: 'Misal: Buat UI Design',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskStatus>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Kolom'),
                items: [
                  for (final s in TaskStatus.values)
                    DropdownMenuItem(value: s, child: Text(s.label)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => status = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: deadline ??
                        DateTime(now.year, now.month, now.day + 1),
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null && context.mounted) {
                    setDialogState(() => deadline = picked);
                  }
                },
                icon: Icon(deadline == null
                    ? Icons.event
                    : Icons.event_available),
                label: Text(deadline == null
                    ? 'Tambah Tenggat'
                    : formatDeadline(deadline!)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                await ref.read(projectRepositoryProvider).addTask(
                      projectId: projectId,
                      name: name,
                      deadline: deadline,
                      status: status,
                    );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    ),
  );
}

void _showEditTaskDialog(
  BuildContext context,
  WidgetRef ref,
  Task task,
) {
  final controller = TextEditingController(text: task.name);

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Ubah Tugas'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Nama Tugas',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isEmpty) return;
            await ref.read(projectRepositoryProvider).renameTask(task.id, name);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Proyek tidak ditemukan')),
    );
  }
}

class _DetailError extends ConsumerWidget {
  const _DetailError();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Gagal memuat detail proyek'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => ref.invalidate(projectsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}