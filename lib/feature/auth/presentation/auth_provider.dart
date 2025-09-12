// lib/feature/auth/presentation/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Student auth model
class StudentAuth {
  final String college;
  final String prn;
  StudentAuth({required this.college, required this.prn});
}

/// Holds current logged in student (null if not logged in)
final authStateProvider = StateProvider<StudentAuth?>((ref) => null);
