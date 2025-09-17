// lib/feature/mood_check/data/mood_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MoodCheckService {
  final CollectionReference moodRef = FirebaseFirestore.instance.collection(
    'mood_check',
  );

  Future<void> saveMood(String prn, String college, int mood) async {
    await moodRef.add({
      'prn': prn,
      'college': college,
      'mood': mood,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
