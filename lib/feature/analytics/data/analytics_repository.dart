import 'analytics_model.dart';
import 'analytics_service.dart';

class AnalyticsRepository {
  final AnalyticsService _service = AnalyticsService();

  Future<void> logMood(MoodLog log) => _service.saveMoodLog(log);

  Future<void> logResource(ResourceLog log) => _service.saveResourceLog(log);

  Future<void> logForum(ForumLog log) => _service.saveForumLog(log);
}
