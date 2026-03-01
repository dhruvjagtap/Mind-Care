class StressTipService {
  static String generateTip(String eventType) {
    switch (eventType.toLowerCase()) {
      case "exam":
        return "Revise in short sessions, take breaks, and sleep well before the exam.";
      case "submission":
        return "Break tasks into smaller parts, start early, and avoid last-minute rush.";
      case "reminder":
        return "Stay consistent, follow your schedule, and celebrate small wins.";
      default:
        return "Take deep breaths, stay positive, and manage your time wisely.";
    }
  }
}
