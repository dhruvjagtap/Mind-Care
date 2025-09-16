// lib/feature/forum/data/forum_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/presentation/profile_provider.dart';

class ForumService {
  final CollectionReference postsRef = FirebaseFirestore.instance.collection(
    'forums',
  );

  Future<void> sendMessage(
    String message, {
    Map<String, dynamic>? replyTo,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await postsRef.add({
      'message': message,
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'reactions': {},
      if (replyTo != null)
        'replyTo': {
          'messageId': replyTo['messageId'],
          'text': replyTo['text'],
          'userId': replyTo['userId'],
        },
    });
  }

  Future<void> reactToPost(String postId, String emoji) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final postDoc = postsRef.doc(postId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postDoc);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final reactions = Map<String, String>.from(data['reactions'] ?? {});

      if (reactions[user.uid] == emoji) {
        // 🔹 Same emoji → remove reaction
        reactions.remove(user.uid);
      } else {
        // 🔹 New or updated emoji → set it
        reactions[user.uid] = emoji;
      }

      transaction.update(postDoc, {'reactions': reactions});
    });
  }

  // // Optional: Delete message for current user only
  Future<void> deleteReplyForMe(String postId, String replyId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final replyDoc = postsRef.doc(postId).collection('replies').doc(replyId);

    await replyDoc.set({
      'hiddenFor': FieldValue.arrayUnion([user.uid]),
    }, SetOptions(merge: true));
  }

  Future<void> deleteMessage(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final postRef = postsRef.doc(postId);
    final post = await postRef.get();

    if (post.exists && post['userId'] == user.uid) {
      // 🔹 First delete all replies under this post
      final repliesSnap = await postRef.collection('replies').get();
      for (final reply in repliesSnap.docs) {
        await reply.reference.delete();
      }

      // 🔹 Now delete the main post itself
      await postRef.delete();
    } else {
      throw Exception("You can only delete your own messages.");
    }
  }

  Future<void> deleteForMe(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await postsRef.doc(postId).set({
      'hiddenFor': FieldValue.arrayUnion([user.uid]),
    }, SetOptions(merge: true));
  }

  Future<void> reportMessage(
    WidgetRef ref,
    String messageId,
    String reason,
  ) async {
    final profile = ref.read(profileNotifierProvider);
    final reporterPrn = profile['prn'];

    if (reporterPrn == null || reporterPrn.toString().isEmpty) {
      throw Exception("PRN not found in profile");
    }

    await FirebaseFirestore.instance.collection('reports').add({
      'messageId': messageId,
      if (reason.isNotEmpty) 'reason': reason,
      'reportedBy': reporterPrn,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Send a new post (optional if you have posts)
  // Future<void> createPost(String title, String message) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   await postsRef.add({
  //     'title': title,
  //     'message': message,
  //     'userId': user.uid,
  //     'createdAt': FieldValue.serverTimestamp(),
  //     'reactions': {}, // map userId → reaction
  //   });
  // }

  // // Send a reply for a post
  // Future<void> addReply(String postId, String message) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   await postsRef.doc(postId).collection('replies').add({
  //     'message': message,
  //     'userId': user.uid,
  //     'createdAt': FieldValue.serverTimestamp(),
  //     'reactions': {},
  //   });
  // }

  // // React to a reply (or post)
  // Future<void> reactToReply(
  //   String postId,
  //   String replyId,
  //   String reaction,
  // ) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;

  //   final replyDoc = postsRef.doc(postId).collection('replies').doc(replyId);

  //   await replyDoc.set({
  //     'reactions': {user.uid: reaction},
  //   }, SetOptions(merge: true));
  // }
}
