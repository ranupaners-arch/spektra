import 'package:flutter/material.dart';

import '../domain/tracking_models.dart';

/// Warna kategori proyek (Kuliah=blue, Klien=green, Pribadi=purple).
/// Dipisah dari domain karena `Color` adalah konsep UI, bukan data.
extension ProjectColorX on Project {
  Color get color => switch (category) {
        ProjectCategory.kuliah => Colors.blue,
        ProjectCategory.klien => Colors.green,
        ProjectCategory.pribadi => Colors.purple,
      };
}