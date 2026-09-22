import 'package:flutter/material.dart';
import '../../tracking/application/project_colors.dart';
import '../../tracking/domain/tracking_models.dart'; // Import yang benar

class QuizScreen extends StatefulWidget {
  final Project project;

  const QuizScreen({super.key, required this.project});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool showResult = false;
  late List<Map<String, dynamic>> questions;

  @override
  void initState() {
    super.initState();
    // Inisialisasi questions di initState, bukan di deklarasi variabel
    _initializeQuestions();
  }

  void _initializeQuestions() {
    int correctCategoryIndex;
    switch (widget.project.category) {
      case ProjectCategory.kuliah:
        correctCategoryIndex = 0;
      case ProjectCategory.klien:
        correctCategoryIndex = 1;
      case ProjectCategory.pribadi:
        correctCategoryIndex = 2;
    }

    int completedTasks = widget.project.tasks.where((t) => t.isDone).length;

    questions = [
      {
        'question': 'Apa progress proyek "${widget.project.title}" saat ini?',
        'options': ['0%', '50%', '75%', '100%'],
        'correct': 2, // Index jawaban benar (75%)
      },
      {
        'question': 'Kategori proyek ini adalah?',
        'options': ['Kuliah', 'Klien', 'Pribadi', 'Lainnya'],
        'correct': correctCategoryIndex,
      },
      {
        'question': 'Berapa jumlah tugas yang sudah selesai?',
        'options': [
          '$completedTasks',
          '${widget.project.tasks.length}',
          '0',
          'Semua'
        ],
        'correct': 0,
      },
    ];
  }

  void checkAnswer(int selectedIndex) {
    if (selectedIndex == questions[currentQuestionIndex]['correct']) {
      setState(() {
        score++;
      });
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        showResult = true;
      });
    }
  }

  void resetQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      showResult = false;
      _initializeQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.project.color.withValues(alpha: 0.05),
      appBar: AppBar(
        title: Text('Kuiz: ${widget.project.title}'),
        backgroundColor: widget.project.color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: showResult ? _buildResultPage() : _buildQuestionPage(),
      ),
    );
  }

  Widget _buildQuestionPage() {
    final question = questions[currentQuestionIndex];
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Progress soal
        Text(
          'Soal ${currentQuestionIndex + 1} dari ${questions.length}',
          style: TextStyle(color: widget.project.color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),
        
        // Pertanyaan
        Text(
          question['question'],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Pilihan jawaban
        ...List.generate(question['options'].length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => checkAnswer(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: widget.project.color.withValues(alpha: 0.3)),
                ),
              ),
              child: Text(
                question['options'][index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResultPage() {
    final percentage = (score / questions.length * 100).toInt();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            percentage >= 70 ? Icons.emoji_events : Icons.stars,
            size: 80,
            color: widget.project.color,
          ),
          const SizedBox(height: 24),
          Text(
            'Skor Kamu: $score/${questions.length}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% Benar',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: resetQuiz,
            icon: const Icon(Icons.refresh),
            label: const Text('Main Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.project.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}