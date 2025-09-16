import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch current student's profile
  Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final college = prefs.getString("college");
    final prn = prefs.getString("prn");

    if (college == null || prn == null) return null;

    final doc = await _firestore
        .collection("colleges")
        .doc(college)
        .collection("students")
        .doc(prn)
        .get();

    return doc.data();
  }

  /// Update profile (merge new data)
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final college = prefs.getString("college");
    final prn = prefs.getString("prn");

    if (college == null || prn == null) return;

    await _firestore
        .collection("colleges")
        .doc(college)
        .collection("students")
        .doc(prn)
        .set(data, SetOptions(merge: true));
  }
}
