// lib/features/shopping_lists/data/models/shopping_list.dart
import 'package:hive/hive.dart';

part 'shopping_list.g.dart';

@HiveType(typeId: 0)
class ShoppingList extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String createdBy;

  @HiveField(3)
  final List<String> sharedWith;

  ShoppingList({
    required this.id,
    required this.name,
    required this.createdBy,
    this.sharedWith = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'createdBy': createdBy,
    'sharedWith': sharedWith,
  };

  factory ShoppingList.fromMap(Map<String, dynamic> map) => ShoppingList(
    id: map['id'],
    name: map['name'],
    createdBy: map['createdBy'],
    sharedWith: List<String>.from(map['sharedWith'] ?? []),
  );
}
