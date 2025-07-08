// lib/core/logic/connectivity_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/shopping_lists/data/models/shopping_list.dart';
import '../../features/shopping_lists/data/models/shopping_item.dart';

final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Emitir estado inicial
  var previousStatus = await connectivity.checkConnectivity();
  yield previousStatus != ConnectivityResult.none;

  // Verificar conexión cada 3 segundos
  await for (final _ in Stream.periodic(const Duration(seconds: 3))) {
    final currentStatus = await connectivity.checkConnectivity();
    final isConnected = currentStatus != ConnectivityResult.none;

    if (currentStatus != previousStatus) {
      previousStatus = currentStatus;

      if (isConnected) {
        final itemsBox = Hive.box<ShoppingItem>('items');
        final listsBox = Hive.box<ShoppingList>('shoppingLists');
        final firestore = FirebaseFirestore.instance;
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final shoppingLists = listsBox.values;

          for (final list in shoppingLists) {
            final firestoreItemsSnapshot = await firestore
                .collection('shopping_lists')
                .doc(list.id)
                .collection('items')
                .get();

            for (final doc in firestoreItemsSnapshot.docs) {
              final serverItem = ShoppingItem.fromMap(doc.data());
              final localItem = itemsBox.get(serverItem.id);
              if (localItem == null ||
                  localItem.checked != serverItem.checked) {
                await itemsBox.put(serverItem.id, serverItem);
              }
            }

            for (final item in itemsBox.values.where(
              (i) => i.listId == list.id,
            )) {
              final itemRef = firestore
                  .collection('shopping_lists')
                  .doc(list.id)
                  .collection('items')
                  .doc(item.id);

              final exists = await itemRef.get();
              if (!exists.exists) {
                await itemRef.set(item.toMap());
              }
            }
          }
        }
      }

      yield isConnected;
    }
  }
});
