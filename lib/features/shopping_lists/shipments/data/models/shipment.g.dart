// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShipmentAdapter extends TypeAdapter<Shipment> {
  @override
  final int typeId = 2;

  @override
  Shipment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Shipment(
      id: fields[0] as String,
      code: fields[1] as String,
      senderName: fields[2] as String,
      receiverName: fields[3] as String,
      status: fields[4] as String,
      createdAt: fields[5] as DateTime,
      createdBy: fields[6] as String,
      ownerEmail: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Shipment obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.senderName)
      ..writeByte(3)
      ..write(obj.receiverName)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.createdBy)
      ..writeByte(7)
      ..write(obj.ownerEmail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShipmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
