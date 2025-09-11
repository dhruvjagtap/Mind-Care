import 'package:cloud_firestore/cloud_firestore.dart';

class Slot {
  final String id;
  final String counselorId;
  final DateTime startAt;
  final DateTime endAt;
  final String? bookedBy;

  Slot({
    required this.id,
    required this.counselorId,
    required this.startAt,
    required this.endAt,
    required this.bookedBy,
  });

  factory Slot.fromDoc(Map<String, dynamic> json, String id) {
    return Slot(
      id: id,
      counselorId: json['counselorId'] as String,
      startAt: (json['startAt'] as Timestamp).toDate(),
      endAt: (json['endAt'] as Timestamp).toDate(),
      bookedBy: json['bookedBy'] as String?,
    );
  }

  bool get isAvailable => bookedBy == null;
}
