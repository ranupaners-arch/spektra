import '../domain/tracking_models.dart';

/// Status tenggat versi UI untuk banner reminder & chip kartu.
///
/// Skala waktu memakai hari kalender (bukan jam) supaya sederhana & konsisten
/// lintas platform. "H-1" = tenggat besok, "H-3" = tenggat tiga hari lagi.
enum DeadlineState {
  /// Sudah lewat tenggat.
  overdue,

  /// Jatuh tempo dalam rentang ≤ 1 hari (H-1).
  dueWithinOneDay,

  /// Jatuh tempo dalam rentang ≤ 3 hari (H-3).
  dueWithinThreeDays,

  /// Ada tenggat tapi masih jauh.
  upcoming,

  /// Tidak punya tenggat.
  none,
}

/// Menghitung [DeadlineState] relatif terhadap `now`.
DeadlineState deadlineState(DateTime? deadline, {DateTime? now}) {
  if (deadline == null) return DeadlineState.none;
  final today = (now ?? DateTime.now());

  final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
  final todayDay = DateTime(today.year, today.month, today.day);
  final diffDays = deadlineDay.difference(todayDay).inDays;

  if (diffDays < 0) return DeadlineState.overdue;
  if (diffDays <= 1) return DeadlineState.dueWithinOneDay;
  if (diffDays <= 3) return DeadlineState.dueWithinThreeDays;
  return DeadlineState.upcoming;
}

/// Label pendek status, misal untuk chip.
String deadlineStateLabel(DeadlineState state) => switch (state) {
      DeadlineState.overdue => 'Terlambat',
      DeadlineState.dueWithinOneDay => 'Tenggat besok',
      DeadlineState.dueWithinThreeDays => 'Tenggat dekat',
      DeadlineState.upcoming => 'Ada tenggat',
      DeadlineState.none => 'Tanpa tenggat',
    };

/// Label "jatuh tempo dalam N hari" / "sudah lewat N hari".
String deadlineRelativeLabel(DateTime deadline, {DateTime? now}) {
  final today = DateTime(now?.year ?? DateTime.now().year,
      now?.month ?? DateTime.now().month, now?.day ?? DateTime.now().day);
  final day =
      DateTime(deadline.year, deadline.month, deadline.day);
  final diffDays = day.difference(today).inDays;

  return switch (diffDays) {
    < 0 => 'Terlambat ${-diffDays} hari',
    0 => 'Jatuh tempo hari ini',
    1 => 'Jatuh tempo besok',
    _ => 'Jatuh tempo dalam $diffDays hari',
  };
}

/// Format tanggal pendek, misal "25 Sep 2026".
String formatDeadline(DateTime deadline) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  return '${deadline.day} ${months[deadline.month - 1]} ${deadline.year}';
}

/// Jumlah task dengan deadline dalam satu project per [DeadlineState].
Map<DeadlineState, int> countDeadlineStates(List<Task> tasks, {DateTime? now}) {
  final counts = <DeadlineState, int>{for (final s in DeadlineState.values) s: 0};
  for (final task in tasks) {
    final state = deadlineState(task.deadline, now: now);
    if (state != DeadlineState.none) counts[state] = counts[state]! + 1;
  }
  return counts;
}