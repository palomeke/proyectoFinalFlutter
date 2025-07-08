// lib/features/shopping_lists/data/models/shopping_item.dart
import 'package:hive/hive.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 1)
class ShoppingItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String listId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final bool checked;

  ShoppingItem({
    required this.id,
    required this.listId,
    required this.name,
    this.checked = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'listId': listId,
    'name': name,
    'checked': checked,
  };

  factory ShoppingItem.fromMap(Map<String, dynamic> map) => ShoppingItem(
    id: map['id'],
    listId: map['listId'],
    name: map['name'],
    checked: map['checked'] ?? false,
  );
}
