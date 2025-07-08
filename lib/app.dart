// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/logic/auth_provider.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/shopping_lists/ui/home_screen.dart';
import 'package:flutter/widgets.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      home: authState.when(
        data: (user) => user != null ? const HomeScreen() : const LoginScreen(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, __) =>
            const Scaffold(body: Center(child: Text('Error de autenticación'))),
      ),
    );
  }
}
