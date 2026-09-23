import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/router.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/presentation/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const ProviderScope(child: SpektraApp()));
}

class SpektraApp extends StatelessWidget {
  const SpektraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Gate();
  }
}

/// Menentukan pintu masuk:
///  * Tanpa konfigurasi Supabase → app local-first, tanpa gate.
///  * Dengan Supabase → layar auth sampai user login; sesudahnya app utama.
class _Gate extends ConsumerWidget {
  const _Gate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final authEnabled = ref.watch(authModuleEnabledProvider);

    return MaterialApp.router(
      title: 'Spektra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: (authEnabled && !isAuthenticated)
          ? _authRouter
          : router,
    );
  }
}

final _authRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthScreen(),
    ),
  ],
);