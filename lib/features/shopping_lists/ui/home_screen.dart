// lib/features/shopping_lists/ui/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../auth/logic/auth_provider.dart';
import '../data/models/shopping_list.dart';

import '../logic/shopping_repository_provider.dart';
import 'item_list_screen.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/widgets/connection_banner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _setupRealtimeSync();
  }

  void _setupRealtimeSync() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('shopping_lists')
        .where('sharedWith', arrayContains: user.email)
        .snapshots()
        .listen((snapshot) async {
          final localBox = Hive.box<ShoppingList>('shoppingLists');
          final remoteLists = snapshot.docs
              .map((doc) => ShoppingList.fromMap(doc.data()))
              .toList();
          final remoteIds = remoteLists.map((l) => l.id).toSet();
          final localIds = localBox.keys.cast<String>().toSet();

          for (final list in remoteLists) {
            await localBox.put(list.id, list);
          }

          for (final localId in localIds.difference(remoteIds)) {
            await localBox.delete(localId);
          }
        });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(shoppingRepositoryProvider);
    final box = Hive.box<ShoppingList>('shoppingLists');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis listas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(firebaseAuthProvider).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const ConnectionBanner(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<ShoppingList> box, _) {
                final lists = box.values.toList();
                if (lists.isEmpty) {
                  return const Center(child: Text('No hay listas disponibles'));
                }
                return ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (_, index) {
                    final list = lists[index];
                    return ListTile(
                      title: Text(list.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemListScreen(list: list),
                          ),
                        );
                      },
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final newNameController = TextEditingController(
                              text: list.name,
                            );
                            final result = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Editar nombre de lista'),
                                content: TextField(
                                  controller: newNameController,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(
                                      context,
                                      newNameController.text,
                                    ),
                                    child: const Text('Guardar'),
                                  ),
                                ],
                              ),
                            );
                            if (result != null && result.trim().isNotEmpty) {
                              await repo.updateListName(list.id, result);
                            }
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar lista'),
                                content: const Text(
                                  '¿Estás seguro que quieres eliminar esta lista?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await repo.deleteList(list.id);
                            }
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Editar')),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Eliminar'),
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nameController = TextEditingController();
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Nueva Lista'),
              content: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la lista',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = ref.read(firebaseAuthProvider).currentUser;
                    if (user != null && nameController.text.trim().isNotEmpty) {
                      final newList = ShoppingList(
                        id: const Uuid().v4(),
                        name: nameController.text.trim(),
                        createdBy: user.uid,
                        sharedWith: [user.email ?? ''],
                      );
                      await repo.addList(newList);
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Crear'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
