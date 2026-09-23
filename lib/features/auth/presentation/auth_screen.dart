import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_controller.dart';

/// Pintu masuk aplikasi saat mode Supabase aktif (user belum login).
///
/// Satu layar dua mode: Masuk / Daftar. Setelah sukses, sesi terpantau oleh
/// [authControllerProvider] dan _SpektraHome_ otomatis dipakai.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _isSignUp = false;
  var _submitting = false;
  String? _message; // pesan error (merah) atau info (mis. "cek email")

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _message = 'Isi email dan password.');
      return;
    }
    if (password.length < 6) {
      setState(() => _message = 'Password minimal 6 karakter.');
      return;
    }

    setState(() {
      _submitting = true;
      _message = null;
    });

    final result = _isSignUp
        ? await ref
            .read(authControllerProvider.notifier)
            .signUp(email: email, password: password)
        : await ref
            .read(authControllerProvider.notifier)
            .signIn(email: email, password: password);

    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (result != null) {
        _message = result;
      } else if (_isSignUp) {
        _message =
            'Akun dibuat. Cek email untuk verifikasi, lalu masuk.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Spektra',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp ? 'Buat akun untuk menyinkronkan data' : 'Masuk untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isSignUp ? 'Daftar' : 'Masuk'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                        _message = null;
                      });
                    },
                    child: Text(_isSignUp ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Daftar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}