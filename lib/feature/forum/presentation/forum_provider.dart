import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/forum_service.dart';

final forumRefProvider = Provider<CollectionReference>((ref) {
  return FirebaseFirestore.instance.collection('forums');
});

final forumServiceProvider = Provider<ForumService>((ref) {
  return ForumService();
});
// Posts stream
final forumPostsProvider = StreamProvider<QuerySnapshot>((ref) {
  final forumRef = ref.watch(forumRefProvider);
  return forumRef.orderBy('createdAt', descending: true).snapshots();
});

// Replies stream for a post
final forumRepliesProvider = StreamProvider.family<QuerySnapshot, String>((
  ref,
  postId,
) {
  final repliesRef = ref
      .watch(forumRefProvider)
      .doc(postId)
      .collection('replies');
  return repliesRef.orderBy('createdAt', descending: false).snapshots();
});

final forumMessagesProvider = StreamProvider<QuerySnapshot>((ref) {
  final forumRef = ref.watch(forumRefProvider);
  return forumRef.orderBy('createdAt', descending: true).snapshots();
});
