import 'package:flutter/material.dart';
import 'project_detail_screen.dart'; // Import halaman detail

// --- MODEL DATA ---
class Task {
  String name;
  bool isDone;
  Task({required this.name, required this.isDone});
}

class Project {
  final String title;
  final String category;
  final Color color;
  List<Task> tasks;

  Project({
    required this.title,
    required this.category,
    required this.color,
    required this.tasks,
  });

  double get progress {
    if (tasks.isEmpty) return 0.0;
    int completedTasks = tasks.where((task) => task.isDone).length;
    return completedTasks / tasks.length;
  }
}

// --- LAYAR UTAMA ---
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final List<Project> _projects = [
    Project(
      title: 'Tugas Akhir Sistem Informasi',
      category: 'Kuliah',
      color: Colors.blue,
      tasks: [
        Task(name: 'Bab 1 Selesai', isDone: true),
        Task(name: 'Presentasi', isDone: false),
      ],
    ),
    Project(
      title: 'Website Klien A',
      category: 'Klien',
      color: Colors.green,
      tasks: [
        Task(name: 'UI Design', isDone: true),
        Task(name: 'Testing', isDone: false),
      ],
    ),
  ];

  void _toggleTask(int projectIndex, int taskIndex) {
    setState(() {
      _projects[projectIndex].tasks[taskIndex].isDone = 
          !_projects[projectIndex].tasks[taskIndex].isDone;
    });
  }

  void _showAddProjectDialog() {
    final titleController = TextEditingController();
    String selectedCategory = 'Kuliah';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Proyek Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Proyek',
                  hintText: 'Misal: Belajar Dart',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: ['Kuliah', 'Klien', 'Pribadi'].map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
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
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  Color projectColor = Colors.blue;
                  if (selectedCategory == 'Klien') projectColor = Colors.green;
                  if (selectedCategory == 'Pribadi') projectColor = Colors.purple;

                  setState(() {
                    _projects.add(Project(
                      title: titleController.text,
                      category: selectedCategory,
                      color: projectColor,
                      tasks: [],
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OmniSpace Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          return _buildProjectCard(index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProjectCard(int index) {
    final project = _projects[index];
    
    // INI DIA PERUBAHANNYA: Bungkus Card dengan InkWell
    return InkWell(
      onTap: () {
        // Pindah ke halaman detail dan kirim data project
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(project: project),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: project.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      project.category,
                      style: TextStyle(color: project.color, fontWeight: FontWeight.bold, fontSize: 12),
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
              const SizedBox(height: 12),
              const Text('Checklist:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...List.generate(project.tasks.length, (taskIndex) {
                final task = project.tasks[taskIndex];
                return CheckboxListTile(
                  title: Text(
                    task.name,
                    style: TextStyle(
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      color: task.isDone ? Colors.grey : Colors.black,
                    ),
                  ),
                  value: task.isDone,
                  onChanged: (val) => _toggleTask(index, taskIndex),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}