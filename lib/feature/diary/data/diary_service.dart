import 'package:cloud_firestore/cloud_firestore.dart';
import 'diary_model.dart';

class DiaryService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveDiaryEntry(DiaryEntry entry) async {
    await _db
        .collection("diary")
        .doc(entry.prn)
        .collection("entries")
        .add(entry.toMap());
  }

  Stream<List<DiaryEntry>> getDiaryEntries(String prn) {
    return _db
        .collection("diary")
        .doc(prn)
        .collection("entries")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return DiaryEntry(
              prn: data["prn"],
              title: data["title"],
              content: data["content"],
              mood: data["mood"],
              timestamp: DateTime.parse(data["timestamp"]),
            );
          }).toList(),
        );
  }
}
