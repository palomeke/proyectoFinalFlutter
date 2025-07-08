// lib/features/shopping_lists/ui/item_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/shopping_list.dart';
import '../data/models/shopping_item.dart';
import '../logic/shopping_repository_provider.dart';
import '../../../shared/widgets/connection_banner.dart';

class ItemListScreen extends ConsumerWidget {
  final ShoppingList list;
  const ItemListScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(shoppingRepositoryProvider);
    final itemsBox = Hive.box<ShoppingItem>('items');
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(list.name)),
      body: Column(
        children: [
          const ConnectionBanner(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(labelText: 'Nuevo ítem'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) return;
                    final newItem = ShoppingItem(
                      id: const Uuid().v4(),
                      listId: list.id,
                      name: controller.text.trim(),
                    );
                    await repo.addItem(newItem);
                    controller.clear();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ShoppingItem>>(
              stream: repo.watchShoppingItems(list.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay ítems aún.'));
                }
                final listItems = snapshot.data!;
                return ListView.builder(
                  itemCount: listItems.length,
                  itemBuilder: (_, index) {
                    final item = listItems[index];
                    return CheckboxListTile(
                      title: Text(item.name),
                      value: item.checked,
                      onChanged: (value) async {
                        await repo.updateItemCheck(
                          item.listId,
                          item.id,
                          value ?? false,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
