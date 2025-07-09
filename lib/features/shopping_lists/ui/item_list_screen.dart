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

  Color _statusColor(ItemStatus status) {
    switch (status) {
      case ItemStatus.inProgress:
        return Colors.yellow;
      case ItemStatus.completed:
        return Colors.green;
      case ItemStatus.notCompleted:
        return Colors.red;
    }
  }

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
                      status: ItemStatus.inProgress,
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
                    return ListTile(
                      title: Text(item.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<ItemStatus>(
                              value: item.status,
                              onChanged: item.status == ItemStatus.completed
                                  ? null
                                  : (value) async {
                                      if (value != null) {
                                        await repo.updateItemStatus(
                                          item.listId,
                                          item.id,
                                          value,
                                        );
                                      }
                                    },
                              items: const [
                                DropdownMenuItem(
                                  value: ItemStatus.notCompleted,
                                  child: Text('No completado'),
                                ),
                                DropdownMenuItem(
                                  value: ItemStatus.inProgress,
                                  child: Text('En proceso'),
                                ),
                                DropdownMenuItem(
                                  value: ItemStatus.completed,
                                  child: Text('Completado'),
                                ),
                              ],
                              icon: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _statusColor(item.status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final controller = TextEditingController(text: item.name);
                            final result = await showDialog<String>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Editar ítem'),
                                content: TextField(controller: controller),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, controller.text),
                                    child: const Text('Guardar'),
                                  ),
                                ],
                              ),
                            );
                            if (result != null && result.trim().isNotEmpty) {
                              await repo.updateItemName(item.listId, item.id, result);
                            }
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Eliminar ítem'),
                                content: const Text('¿Estás seguro?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await repo.deleteItem(item.listId, item.id);
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                        ],
                      ),
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
