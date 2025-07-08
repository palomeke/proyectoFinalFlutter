// lib/core/services/hive_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

import '../../features/shopping_lists/data/models/shopping_list.dart';
import '../../features/shopping_lists/data/models/shopping_item.dart';
import '../../features/shopping_lists/shipments/data/models/shipment.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ShoppingListAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ShoppingItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ShipmentAdapter());
    }

    await Hive.openBox<ShoppingList>('shoppingLists');
    await Hive.openBox<ShoppingItem>('items');
    await Hive.openBox<Shipment>('shipments');
  }
}
