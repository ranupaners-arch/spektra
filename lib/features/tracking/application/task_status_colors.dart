import 'package:flutter/material.dart';

import '../domain/tracking_models.dart';

/// Warna aksen per status kanban. Dipisah dari domain karena `Color`
/// adalah konsep UI, bukan data.
extension TaskStatusColorX on TaskStatus {
  Color get color => switch (this) {
        TaskStatus.todo => const Color(0xFF6B7280),
        TaskStatus.inProgress => Colors.blue,
        TaskStatus.review => Colors.orange,
        TaskStatus.done => Colors.green,
      };
}