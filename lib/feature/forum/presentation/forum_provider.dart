import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final forumRefProvider = Provider<CollectionReference>((ref) {
  return FirebaseFirestore.instance.collection('forums');
});

final forumMessagesProvider = StreamProvider<QuerySnapshot>((ref) {
  final forumRef = ref.watch(forumRefProvider);
  return forumRef.orderBy('createdAt', descending: true).snapshots();
});
