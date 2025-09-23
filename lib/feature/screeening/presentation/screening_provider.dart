import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/screening_repository.dart';
import '../data/screening_model.dart';
import '../../auth/presentation/auth_provider.dart';

/// Which test user selected
final selectedTestProvider = StateProvider<String?>((ref) => null);

/// Answers chosen by the user for PHQ-9
final phq9AnswersProvider = StateProvider<List<int>>((ref) => []);

/// Answers chosen by the user for GAD-7
final gad7AnswersProvider = StateProvider<List<int>>((ref) => []);

/// Generic getter for current test answers
StateProvider<List<int>> answersProviderForTest(String? testType) {
  if (testType == "PHQ-9") {
    return phq9AnswersProvider;
  } else if (testType == "GAD-7") {
    return gad7AnswersProvider;
  } else {
    return StateProvider<List<int>>((ref) => []);
  }
}

/// Score calculator for a list of answers
Provider<int> scoreProviderForAnswers(
  StateProvider<List<int>> answersProvider,
) {
  return Provider<int>((ref) {
    final answers = ref.watch(answersProvider);
    return answers.fold(0, (sum, a) => sum + a);
  });
}

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

  // Use the correct answers provider based on test type
  final answersProvider = answersProviderForTest(testType); // PHQ-9 or GAD-7
  final answers = ref.read(answersProvider);
  final score = answers.fold(0, (sum, a) => sum + a);

  final result = ScreeningResult(
    prn: prn,
    college: college,
    testType: testType,
    answers: answers,
    score: score,
    createdAt: DateTime.now(),
  );

  await repo.saveResult(result);
});
