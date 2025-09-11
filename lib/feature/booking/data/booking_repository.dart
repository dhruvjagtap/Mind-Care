// data/booking_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './booking_model.dart';
import './slots_model.dart';

class BookingRepository {
  BookingRepository(this._db, this._auth);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  Stream<List<Counselor>> streamCounselors() {
    return _db
        .collection('counselors')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Counselor.fromDoc(d.data(), d.id)).toList(),
        );
  }

  // Stream<List<Slot>> streamAvailableSlots({
  //   required String counselorId,
  //   required DateTime day, // filter by day (00:00–23:59)
  // }) {
  //   final start = DateTime(day.year, day.month, day.day);
  //   final end = start.add(const Duration(days: 1));
  //   return _db
  //       .collection('counselor_slots')
  //       .where('counselorId', isEqualTo: counselorId)
  //       .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
  //       .where('startAt', isLessThan: Timestamp.fromDate(end))
  //       .orderBy('startAt')
  //       .snapshots()
  //       .map(
  //         (snap) => snap.docs
  //             .map((d) => Slot.fromDoc(d.data(), d.id))
  //             .where((s) => s.isAvailable) // show only free slots
  //             .toList(),
  //       );
  // }

  Stream<List<Slot>> streamAvailableSlots({
    required String counselorId,
    required DateTime day,
  }) {
    return _db.collection('counselor_slots').snapshots().map((snap) {
      // print("DEBUG: Raw slots count = ${snap.docs.length}");
      // for (final d in snap.docs) {
      //   print("DEBUG slot: ${d.id} => ${d.data()}");
      // }
      return snap.docs.map((d) => Slot.fromDoc(d.data(), d.id)).toList();
    });
  }

  /// Atomically books a slot if still free
  Future<void> bookSlot({
    required String slotId,
    required String counselorId,
    String? note,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Not authenticated');
    }

    final slotRef = _db.collection('counselor_slots').doc(slotId);
    final bookingRef = _db.collection('bookings').doc();

    await _db.runTransaction((txn) async {
      final slotSnap = await txn.get(slotRef);
      if (!slotSnap.exists) {
        throw Exception('Slot no longer exists');
      }
      final slotData = slotSnap.data() as Map<String, dynamic>;
      if (slotData['bookedBy'] != null) {
        throw Exception('Slot already booked');
      }

      // Mark slot booked
      txn.update(slotRef, {'bookedBy': uid});

      // Create booking doc
      txn.set(bookingRef, {
        'studentId': uid,
        'counselorId': counselorId,
        'slotId': slotId,
        'status': 'booked',
        'createdAt': FieldValue.serverTimestamp(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      });
    });
  }

  Stream<List<Map<String, dynamic>>> streamMyBookings() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('bookings')
        .where('studentId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  Future<void> cancelBooking(String bookingId, String slotId) async {
    final uid = _auth.currentUser?.uid;
    final bookingRef = _db.collection('bookings').doc(bookingId);
    final slotRef = _db.collection('counselor_slots').doc(slotId);

    await _db.runTransaction((txn) async {
      final bookingSnap = await txn.get(bookingRef);
      if (!bookingSnap.exists) return;

      final data = bookingSnap.data() as Map<String, dynamic>;
      if (data['studentId'] != uid) {
        throw Exception('Not your booking');
      }

      txn.update(bookingRef, {'status': 'cancelled'});
      txn.update(slotRef, {'bookedBy': null});
    });
  }
}
