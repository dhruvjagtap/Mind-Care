class DiaryEntry {
  final String prn;
  final String title;
  final String content;
  final int mood; // 1 = happy, 0 = neutral, -1 = sad
  final DateTime timestamp;

  DiaryEntry({
    required this.prn,
    required this.title,
    required this.content,
    required this.mood,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    "prn": prn,
    "title": title,
    "content": content,
    "mood": mood,
    "timestamp": timestamp.toIso8601String(),
  };
}
