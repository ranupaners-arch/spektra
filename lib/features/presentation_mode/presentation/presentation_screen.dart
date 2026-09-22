import 'package:flutter/material.dart';
import '../../tracking/application/project_colors.dart';
import '../../tracking/domain/tracking_models.dart';

class PresentationScreen extends StatelessWidget {
  final Project project;

  const PresentationScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih ala slide
      body: Stack(
        children: [
          // Konten Slide (PageView)
          PageView(
            children: [
              _buildTitleSlide(),    // Slide 1: Judul & Progress
              _buildChecklistSlide(), // Slide 2: Daftar Tugas
            ],
          ),
          
          // Tombol Exit (Pojok Kanan Atas)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black54, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Indikator Slide (Pojok Kanan Bawah)
          Positioned(
            bottom: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Geser untuk ganti slide →',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SLIDE 1: JUDUL & PROGRESS ---
  Widget _buildTitleSlide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label Kategori
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: project.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                project.category.label.toUpperCase(),
                style: TextStyle(
                  color: project.color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Judul Proyek Besar
            Text(
              project.title,
              style: const TextStyle(
                fontSize: 42, // Font besar ala presentasi
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            
            // Progress Bar Raksasa
            const Text("Progress Keseluruhan", style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: project.progress,
                backgroundColor: Colors.grey[200],
                color: project.color,
                minHeight: 20, // Lebih tebal
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(project.progress * 100).toInt()}% Selesai',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: project.color
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SLIDE 2: CHECKLIST / MILESTONES ---
  Widget _buildChecklistSlide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Milestones & Tugas",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            
            // List Tugas
            Expanded(
              child: ListView.builder(
                itemCount: project.tasks.length,
                itemBuilder: (context, index) {
                  final task = project.tasks[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: task.isDone ? Colors.green.withValues(alpha: 0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: task.isDone ? Colors.green : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          task.isDone ? Icons.check_circle : Icons.circle_outlined,
                          color: task.isDone ? Colors.green : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            task.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: task.isDone ? FontWeight.bold : FontWeight.normal,
                              color: task.isDone ? Colors.green[800] : Colors.black87,
                              decoration: task.isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}