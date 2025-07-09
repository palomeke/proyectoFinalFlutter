// lib/features/shopping_lists/data/models/shopping_item.dart
import 'package:hive/hive.dart';

enum ItemStatus { notCompleted, inProgress, completed }

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

  @HiveField(4)
  final ItemStatus status;

  ShoppingItem({
    required this.id,
    required this.listId,
    required this.name,
    this.checked = false,
    this.status = ItemStatus.notCompleted,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'listId': listId,
    'name': name,
    'checked': checked,
    'status': status.name,
  };

  factory ShoppingItem.fromMap(Map<String, dynamic> map) => ShoppingItem(
    id: map['id'],
    listId: map['listId'],
    name: map['name'],
    checked: map['checked'] ?? false,
    status: ItemStatus.values.byName(
      map['status'] ?? ItemStatus.notCompleted.name,
    ),
  );
}
