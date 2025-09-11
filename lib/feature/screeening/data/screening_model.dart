class ScreeningResult {
  final String userId;
  final String testType;
  final List<int> answers;
  final int score;
  final DateTime createdAt;

  ScreeningResult({
    required this.userId,
    required this.testType,
    required this.answers,
    required this.score,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'testType': testType,
    'answers': answers,
    'score': score,
    'createdAt': createdAt.toIso8601String(),
  };
}
