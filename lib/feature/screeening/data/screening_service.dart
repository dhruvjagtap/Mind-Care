// lib/feature/screeening/data/screening_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/screening_repository.dart';
import '../data/screening_model.dart';
import '../../auth/presentation/auth_provider.dart';

/// Which test user selected
final selectedTestProvider = StateProvider<String?>((ref) => null);

/// Answers chosen by the user
final answersProvider = StateProvider<List<int>>((ref) => []);

/// Score calculator
final scoreProvider = Provider<int>((ref) {
  final answers = ref.watch(answersProvider);
  return answers.fold(0, (sum, a) => sum + a);
});

/// Repository provider
final screeningRepositoryProvider = Provider<ScreeningRepository>((ref) {
  return ScreeningRepository();
});

/// Action: save result
final saveResultProvider = FutureProvider.family<void, String>((
  ref,
  testType,
) async {
  final repo = ref.read(screeningRepositoryProvider);
  final student = ref.read(authStateProvider);
  if (student == null) throw Exception("Student profile not found");
  final college = student.college;
  final prn = student.prn;
  final answers = ref.read(answersProvider);
  final score = ref.read(scoreProvider);

  final result = ScreeningResult(
    college: college,
    prn: prn,
    testType: testType,
    answers: answers,
    score: score,
    createdAt: DateTime.now(),
  );

  await repo.saveResult(result);
});
