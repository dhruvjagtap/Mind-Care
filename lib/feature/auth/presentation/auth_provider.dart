import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_service.dart';

// Provide AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provide auth state stream (listens to Firebase user changes)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});
