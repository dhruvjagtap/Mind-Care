// lib/feature/analytics/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'analytics_model.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  final _db = FirebaseFirestore.instance;

  Future<void> saveMoodLog(MoodLog log) async {
    await _db
        .collection("analytics")
        .doc(log.prn)
        .collection("mood_logs")
        .add(log.toMap());
  }

  Future<void> saveResourceLog(ResourceLog log) async {
    await _db
        .collection("analytics")
        .doc(log.prn)
        .collection("resource_logs")
        .add(log.toMap());
  }

  Future<void> saveForumLog(ForumLog log) async {
    await _db
        .collection("analytics")
        .doc(log.prn)
        .collection("forum_logs")
        .add(log.toMap());
  }

  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    await _analytics.logEvent(name: name, parameters: params);
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}

final analyticsService = AnalyticsService();
