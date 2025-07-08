// lib/features/shopping_lists/logic/shopping_lists_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive/hive.dart';
import '../data/models/shopping_list.dart';
import '../data/models/shopping_item.dart';

import 'shopping_repository_provider.dart';

final shoppingListsLocalProvider = Provider<Box<ShoppingList>>((ref) {
  return Hive.box<ShoppingList>('shoppingLists');
});

final shoppingListsProvider = FutureProvider.autoDispose<List<ShoppingList>>((
  ref,
) async {
  final repo = ref.read(shoppingRepositoryProvider);
  return repo.syncLists();
});

final shoppingItemsLocalProvider = Provider<Box<ShoppingItem>>((ref) {
  return Hive.box<ShoppingItem>('items');
});

final shoppingItemsProvider = Provider.family<List<ShoppingItem>, String>((
  ref,
  listId,
) {
  final itemsBox = ref.watch(shoppingItemsLocalProvider);
  return itemsBox.values.where((item) => item.listId == listId).toList();
});
