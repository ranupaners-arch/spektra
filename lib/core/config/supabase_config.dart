/// Konfigurasi Supabase. Nilai di-inject saat build via `--dart-define`:
///
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
///
/// Jika tidak di-set, app berjalan local-first (Drift/SQLite) seperti biasa —
/// tidak ada kode yang menyentuh Supabase. Ini menjaga "offline first" tetap
/// jadi default sampai backend benar-benar dipakai.
library;

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

class SupabaseConfig {
  const SupabaseConfig._();

  /// URL project Supabase (mis. `https://xxxx.supabase.co`).
  static const String url = _supabaseUrl;

  /// Public `anon` key — aman dibaca client.
  static const String anonKey = _supabaseAnonKey;

  /// `true` bila project Supabase sudah dikonfigurasi (URL + key terisi).
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}