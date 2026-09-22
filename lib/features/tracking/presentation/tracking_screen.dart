import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/project_colors.dart';
import '../application/tracking_providers.dart';
import '../domain/tracking_models.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spektra Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: switch (projectsAsync) {
        AsyncData(:final value) when value.isEmpty =>
          _EmptyState(onAddPressed: () => _showAddProjectDialog(context, ref)),
        AsyncData(:final value) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: value.length,
            itemBuilder: (context, index) => _ProjectCard(project: value[index]),
          ),
        AsyncError(:final error) => _ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(projectsProvider),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context, ref),
        tooltip: 'Tambah Proyek',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    var selectedCategory = ProjectCategory.kuliah;

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Tambah Proyek Baru'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Judul Proyek',
                    hintText: 'Misal: Belajar Dart',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProjectCategory>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: [
                    for (final category in ProjectCategory.values)
                      DropdownMenuItem(
                        value: category,
                        child: Text(category.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
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
                  final title = controller.text.trim();
                  if (title.isEmpty) return;

                  final repository =
                      ref.read(projectRepositoryProvider);
                  await repository.addProject(
                    title: title,
                    category: selectedCategory,
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
}

/// Kartu proyek tampil saat data sudah ada.
class _ProjectCard extends ConsumerWidget {
  const _ProjectCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/project/${project.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: project.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      project.category.label,
                      style: TextStyle(
                        color: project.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: project.progress,
                  backgroundColor: Colors.grey[200],
                  color: project.color,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(project.progress * 100).toInt()}% Selesai',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              if (project.tasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Checklist:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                for (final task in project.tasks)
                  CheckboxListTile(
                    title: Text(
                      task.name,
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isDone ? Colors.grey : Colors.black,
                      ),
                    ),
                    value: task.isDone,
                    onChanged: (_) => _toggleTask(ref, task),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _toggleTask(WidgetRef ref, Task task) {
    ref.read(projectRepositoryProvider).setTaskStatus(
          task.id,
          task.isDone ? TaskStatus.todo : TaskStatus.done,
        );
  }
}

/// Ditampilkan saat belum ada proyek sama sekali.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.space_dashboard_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada proyek',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Buat proyek pertama untuk mulai tracking tugas.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Proyek Pertama'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ditampilkan saat gagal membaca database.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}