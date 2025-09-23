class ActivityLog {
  final String prn;
  final String activityName; // e.g. "breathing", "memory_game"
  final int duration; // minutes
  final int? moodBefore;
  final int? moodAfter;
  final DateTime timestamp;

  ActivityLog({
    required this.prn,
    required this.activityName,
    required this.duration,
    this.moodBefore,
    this.moodAfter,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    "prn": prn,
    "activityName": activityName,
    "duration": duration,
    "moodBefore": moodBefore,
    "moodAfter": moodAfter,
    "timestamp": timestamp.toIso8601String(),
  };
}
