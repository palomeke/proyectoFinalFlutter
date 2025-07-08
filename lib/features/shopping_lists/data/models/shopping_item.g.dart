// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingItemAdapter extends TypeAdapter<ShoppingItem> {
  @override
  final int typeId = 1;

  @override
  ShoppingItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingItem(
      id: fields[0] as String,
      listId: fields[1] as String,
      name: fields[2] as String,
      checked: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.listId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.checked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
