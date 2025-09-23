class MoodLog {
  final String prn;
  final int mood; // 1 = happy, 0 = neutral, -1 = sad
  final DateTime timestamp;

  MoodLog({required this.prn, required this.mood, required this.timestamp});

  Map<String, dynamic> toMap() => {
    "prn": prn,
    "mood": mood,
    "timestamp": timestamp.toIso8601String(),
  };
}

class ResourceLog {
  final String prn;
  final String resourceId;
  final String type; // video | audio | pdf
  final DateTime timestamp;

  ResourceLog({
    required this.prn,
    required this.resourceId,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    "prn": prn,
    "resourceId": resourceId,
    "type": type,
    "timestamp": timestamp.toIso8601String(),
  };
}

class ForumLog {
  final String prn;
  final String postId;
  final String action; // post | reply
  final DateTime timestamp;

  ForumLog({
    required this.prn,
    required this.postId,
    required this.action,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    "prn": prn,
    "postId": postId,
    "action": action,
    "timestamp": timestamp.toIso8601String(),
  };
}
