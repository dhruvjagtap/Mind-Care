// lib/feature/mood_check/data/mood_model.dart
class MoodCheck {
  final String prn;
  final String college;
  final String mood;
  final DateTime timestamp;

  MoodCheck({
    required this.prn,
    required this.college,
    required this.mood,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'prn': prn,
    'college': college,
    'mood': mood,
    'timestamp': timestamp.toIso8601String(),
  };
}
