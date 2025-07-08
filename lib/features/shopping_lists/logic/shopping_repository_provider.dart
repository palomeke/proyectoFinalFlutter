// lib/features/shopping_lists/logic/shopping_repository_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../data/shopping_repository.dart';
import '../data/models/shopping_list.dart';
import '../data/models/shopping_item.dart';

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final listBox = Hive.box<ShoppingList>('shoppingLists');
  final itemBox = Hive.box<ShoppingItem>('items');

  return ShoppingRepository(
    firestore: firestore,
    auth: auth,
    listBox: listBox,
    itemBox: itemBox,
  );
});