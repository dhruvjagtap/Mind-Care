import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      return data; // success
    }
    return null; // wrong pin
  }

  Future<void> registerPRN(String college, String prn, String pin) async {
    await _firestore
        .collection("colleges")
        .doc(college)
        .collection("students")
        .doc(prn)
        .set({
          "pinHash": pin,
          "isOnboarded": false,
          "createdAt": FieldValue.serverTimestamp(),
        });
  }
}
