// providers/booking_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/booking_repository.dart';
import '../data/booking_model.dart';
import '../data/slots_model.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

final bookingRepoProvider = Provider(
  (ref) => BookingRepository(
    ref.read(firestoreProvider),
    ref.read(firebaseAuthProvider),
  ),
);

final counselorsProvider = StreamProvider.autoDispose<List<Counselor>>(
  (ref) => ref.read(bookingRepoProvider).streamCounselors(),
);

class SlotsQuery {
  final String counselorId;
  final DateTime day;
  SlotsQuery(this.counselorId, this.day);
}

final availableSlotsProvider = StreamProvider.autoDispose
    .family<List<Slot>, SlotsQuery>((ref, q) {
      return ref
          .read(bookingRepoProvider)
          .streamAvailableSlots(counselorId: q.counselorId, day: q.day);
    });

final myBookingsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>(
      (ref) => ref.read(bookingRepoProvider).streamMyBookings(),
    );

final bookingActionProvider = StateProvider<AsyncValue<void>>(
  (_) => const AsyncData(null),
);
