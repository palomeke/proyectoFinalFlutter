import 'package:hive/hive.dart';

part 'shipment.g.dart';

@HiveType(typeId: 2)
class Shipment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String code;

  @HiveField(2)
  final String senderName;

  @HiveField(3)
  final String receiverName;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final String createdBy;

  @HiveField(7)
  final String ownerEmail;

  Shipment({
    required this.id,
    required this.code,
    required this.senderName,
    required this.receiverName,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    required this.ownerEmail,
  });

  factory Shipment.fromMap(Map<String, dynamic> map) => Shipment(
    id: map['id'],
    code: map['code'],
    senderName: map['senderName'],
    receiverName: map['receiverName'],
    status: map['status'],
    createdAt: DateTime.parse(map['createdAt']),
    createdBy: map['createdBy'],
    ownerEmail: map['ownerEmail'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'code': code,
    'senderName': senderName,
    'receiverName': receiverName,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'createdBy': createdBy,
    'ownerEmail': ownerEmail,
  };
}
