// lib/shared/widgets/connection_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logic/connectivity_provider.dart';

class ConnectionBanner extends ConsumerWidget {
  const ConnectionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectivityStatusProvider);

    return connection.when(
      data: (isOnline) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: isOnline ? Colors.green : Colors.red,
          child: Text(
            isOnline ? 'Conectado' : 'Sin conexión',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
      },
      loading: () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: Colors.grey,
        child: const Text(
          'Cargando estado de conexión...',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      error: (_, __) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: Colors.grey,
        child: const Text(
          'Error de conexión',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
