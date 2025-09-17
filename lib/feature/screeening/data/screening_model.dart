// lib/feature/screeening/data/screening_model.dart
class ScreeningResult {
  final String prn;
  final String college;
  final String testType;
  final List<int> answers;
  final int score;
  final DateTime createdAt;

  ScreeningResult({
    required this.prn,
    required this.college,
    required this.testType,
    required this.answers,
    required this.score,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'prn': prn,
    'college': college,
    'testType': testType,
    'answers': answers,
    'score': score,
    'createdAt': createdAt.toIso8601String(),
  };
}
