import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';

/// Auth state global. `null` = belum login (atau auth nonaktif saat app
/// berjalan tanpa konfigurasi Supabase — offline-first).
class AuthController extends Notifier<Session?> {
  StreamSubscription<AuthState>? _subscription;

  @override
  Session? build() {
    final client = Supabase.instance.client;
    _subscription = client.auth.onAuthStateChange.listen((authState) {
      state = authState.session;
    });
    ref.onDispose(() => _subscription?.cancel());
    return client.auth.currentSession;
  }

  bool get isAuthenticated => state != null;

  /// Login email+password. Mengembalikan `null` bila sukses, atau pesan error.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  /// Register email+password. Mengembalikan `null` bila sukses.
  ///
  /// Bila email confirmation aktif di dashboard, sesi belum terbentuk sampai
  /// email diverifikasi — supabase tetap mengembalikan sukses di sini, dan UI
  /// wajib memberi tahu user "cek email".
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

/// `true` bila project Supabase dikonfigurasi → auth gate aktif.
final authModuleEnabledProvider = Provider<bool>(
  (ref) => SupabaseConfig.isConfigured,
);

/// Controller auth. Hanya aman dibaca bila [authModuleEnabledProvider] true
/// (butuh Supabase.instance ter-initialize).
final authControllerProvider =
    NotifierProvider<AuthController, Session?>(AuthController.new);

/// `true` bila user sudah login — atau bila auth nonaktif (offline-first,
/// app harus tetap jalan penuh tanpa Supabase).
final isAuthenticatedProvider = Provider<bool>((ref) {
  if (!ref.watch(authModuleEnabledProvider)) return true;
  return ref.watch(authControllerProvider) != null;
});