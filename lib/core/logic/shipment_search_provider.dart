import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/shopping_lists/data/models/shopping_list.dart';

final shipmentSearchProvider = FutureProvider.family<ShoppingList?, String>((
  ref,
  code,
) async {
  if (code.isEmpty) return null;
  final doc = await FirebaseFirestore.instance
      .collection('shopping_lists')
      .doc(code)
      .get();
  if (!doc.exists) return null;
  return ShoppingList.fromMap(doc.data()!);
});
