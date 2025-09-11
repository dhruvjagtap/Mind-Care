import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get UID of current anonymous user
  String? get uid => _auth.currentUser?.uid;

  // Fetch profile
  Future<Map<String, dynamic>?> getProfile() async {
    if (uid == null) return null;
    final doc = await _firestore.collection('profiles').doc(uid).get();
    return doc.data();
  }

  // Create/Update profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (uid == null) return;
    await _firestore
        .collection('profiles')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }
}
