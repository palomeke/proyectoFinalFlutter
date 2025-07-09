// lib/features/shopping_lists/data/shopping_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/shopping_list.dart';
import 'models/shopping_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity() != ConnectivityResult.none;
  await for (final status in connectivity.onConnectivityChanged) {
    yield status != ConnectivityResult.none;
  }
});

class ShoppingRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Box<ShoppingList> listBox;
  final Box<ShoppingItem> itemBox;

  ShoppingRepository({
    required this.firestore,
    required this.auth,
    required this.listBox,
    required this.itemBox,
  });

  Future<List<ShoppingList>> syncLists() async {
    final user = auth.currentUser;
    if (user == null) return [];

    final sharedSnap = await firestore
        .collection('shopping_lists')
        .where('sharedWith', arrayContains: user.email)
        .get();

    final ownSnap = await firestore
        .collection('shopping_lists')
        .where('createdBy', isEqualTo: user.uid)
        .get();

    final lists = [
      ...sharedSnap.docs,
      ...ownSnap.docs,
    ].map((doc) => ShoppingList.fromMap(doc.data())).toList();

    for (final list in lists) {
      await listBox.put(list.id, list);
    }

    return listBox.values.toList();
  }

  Future<void> syncItems(String listId) async {
    final itemsSnap = await firestore
        .collection('shopping_lists')
        .doc(listId)
        .collection('items')
        .get();

    for (final doc in itemsSnap.docs) {
      final serverItem = ShoppingItem.fromMap(doc.data());
      final localItem = itemBox.get(serverItem.id);

      if (localItem == null ||
          localItem.status != serverItem.status ||
          localItem.name != serverItem.name) {
        await itemBox.put(serverItem.id, serverItem);
      }
    }

    for (final item in itemBox.values.where((i) => i.listId == listId)) {
      final itemRef = firestore
          .collection('shopping_lists')
          .doc(listId)
          .collection('items')
          .doc(item.id);

      final exists = await itemRef.get();
      if (!exists.exists) {
        await itemRef.set(item.toMap());
      }
    }
  }

  Future<void> addList(ShoppingList list) async {
    await listBox.put(list.id, list); // guardar local primero
    try {
      await firestore
          .collection('shopping_lists')
          .doc(list.id)
          .set(list.toMap());
    } catch (e) {
      debugPrint('Fallo al agregar lista en Firestore: $e');
    }
  }

  Future<void> deleteList(String listId) async {
    await listBox.delete(listId); // eliminar local primero
    try {
      await firestore.collection('shopping_lists').doc(listId).delete();
    } catch (e) {
      debugPrint('Fallo al eliminar lista en Firestore: $e');
    }
  }

  Future<void> updateListName(String listId, String newName) async {
    final list = listBox.get(listId);
    if (list != null) {
      final updated = ShoppingList(
        id: list.id,
        name: newName,
        createdBy: list.createdBy,
        sharedWith: list.sharedWith,
      );
      await listBox.put(listId, updated);

      try {
        await firestore.collection('shopping_lists').doc(listId).update({
          'name': newName,
        });
      } catch (e) {
        debugPrint('Fallo al actualizar nombre en Firestore: $e');
      }
    }
  }

  Future<void> addItem(ShoppingItem item) async {
    await itemBox.put(item.id, item); // guardar local siempre primero
    try {
      await firestore
          .collection('shopping_lists')
          .doc(item.listId)
          .collection('items')
          .doc(item.id)
          .set(item.toMap());
    } catch (e) {
      debugPrint('Fallo al sincronizar con Firestore: $e');
    }
  }

  Stream<List<ShoppingItem>> watchShoppingItems(String listId) {
    return FirebaseFirestore.instance
        .collection('shopping_lists')
        .doc(listId)
        .collection('items')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return ShoppingItem.fromMap(doc.data());
          }).toList(),
        );
  }

  Stream<List<ShoppingList>> watchShoppingLists() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('shopping_lists')
        .where('sharedWith', arrayContains: user.email)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ShoppingList.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> updateItemStatus(
    String listId,
    String itemId,
    ItemStatus status,
  ) async {
    final item = itemBox.get(itemId);
    if (item == null) return;

    final updated = ShoppingItem(
      id: item.id,
      listId: item.listId,
      name: item.name,
      checked: item.checked,
      status: status,
    );

    await itemBox.put(itemId, updated);

    try {
      await firestore
          .collection('shopping_lists')
          .doc(listId)
          .collection('items')
          .doc(itemId)
          .update({'status': status.name});
    } catch (e) {
      debugPrint('Fallo al actualizar estado en Firestore: $e');
    }
  }

  Future<void> updateItemName(
    String listId,
    String itemId,
    String newName,
  ) async {
    final item = itemBox.get(itemId);
    if (item == null) return;

    final updated = ShoppingItem(
      id: item.id,
      listId: item.listId,
      name: newName,
      checked: item.checked,
      status: item.status,
    );

    await itemBox.put(itemId, updated);

    try {
      await firestore
          .collection('shopping_lists')
          .doc(listId)
          .collection('items')
          .doc(itemId)
          .update({'name': newName});
    } catch (e) {
      debugPrint('Fallo al actualizar nombre en Firestore: $e');
    }
  }

  Future<void> deleteItem(String listId, String itemId) async {
    await itemBox.delete(itemId);
    try {
      await firestore
          .collection('shopping_lists')
          .doc(listId)
          .collection('items')
          .doc(itemId)
          .delete();
    } catch (e) {
      debugPrint('Fallo al eliminar item en Firestore: $e');
    }
  }
}
