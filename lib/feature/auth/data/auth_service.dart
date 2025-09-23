// lib/feature/auth/data/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
    final firebasePrn = data["prn"];
    final firebasePin = data["pinHash"];

    if (firebasePrn == prn && firebasePin == pin) {
      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("college", college);
      await prefs.setString("prn", prn);

      final token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await _firestore
            .collection("colleges")
            .doc(college)
            .collection("students")
            .doc(prn)
            .update({"deviceToken": token});
      }

      return data;
    }

    return null; // invalid PRN or PIN
  }

  /// 2. Register new student (during onboarding)
  Future<void> registerPRN({
    required String college,
    required String prn,
    required String pin,
    required String name,
    required List<String> hobbies,
  }) async {
    final token = await FirebaseMessaging.instance.getToken();
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
          "deviceToken": token,
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
