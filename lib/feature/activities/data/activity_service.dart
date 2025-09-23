import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_model.dart';

class ActivityService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveActivity(ActivityLog log) async {
    await _db
        .collection("activities")
        .doc(log.prn)
        .collection("logs")
        .add(log.toMap());
  }
}
