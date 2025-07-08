import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/logic/shipment_search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(shipmentSearchProvider(_controller.text.trim()));

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Encomienda')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Código de encomienda',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            result.when(
              data: (shipment) {
                if (shipment == null) {
                  return const Text('No se encontró ninguna encomienda.');
                }
                return Card(
                  child: ListTile(
                    title: Text(shipment.name),
                    subtitle: Text('ID: ${shipment.id}'),
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
