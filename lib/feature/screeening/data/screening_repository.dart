import 'package:cloud_firestore/cloud_firestore.dart';
import 'screening_model.dart';

class ScreeningRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> saveResult(ScreeningResult result) async {
    await _db.collection("screening").add(result.toMap());
  }
}
