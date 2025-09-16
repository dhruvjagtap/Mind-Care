// lib/feature/auth/data/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 1. Login with PRN + PIN
  Future<Map<String, dynamic>?> loginWithPRN(
    String college,
    String prn,
    String pin,
  ) async {
    final doc = await _firestore
        .collection("colleges")
        .doc(college)
        .collection("students")
        .doc(prn)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    if (data["pinHash"] == pin) {
      // ✅ Save session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("college", college);
      await prefs.setString("prn", prn);
      return data;
    }
    return null;
  }

  /// 2. Register new student (during onboarding)
  Future<void> registerPRN({
    required String college,
    required String prn,
    required String pin,
    required String name,
    required List<String> hobbies,
  }) async {
    await _firestore
        .collection("colleges")
        .doc(college)
        .collection("students")
        .doc(prn)
        .set({
          "pinHash": pin,
          "name": name,
          "prn": prn, // ✅ add this
          "college": college, // ✅ add this
          "hobbies": hobbies,
          "isOnboarded": true,
          "createdAt": FieldValue.serverTimestamp(),
        });

    // ✅ Save session locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("college", college);
    await prefs.setString("prn", prn);
  }

  /// 3. Check if a student exists (for deciding Register vs Login)
  Future<bool> checkStudentExists(String college, String prn) async {
    final doc = await _firestore
        .collection("colleges")
        .doc(college)
        .collection("students")
        .doc(prn)
        .get();
    return doc.exists;
  }

  /// 4. Logout → clear local prefs only
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("college");
    await prefs.remove("prn");
    await prefs.remove("isOnboarded"); // optional if you’re storing this
  }
}
