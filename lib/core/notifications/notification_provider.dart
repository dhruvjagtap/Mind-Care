import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

/// Tracks last notification state (true when one was sent)
final notificationProvider = StateNotifierProvider<NotificationNotifier, bool>((
  ref,
) {
  return NotificationNotifier();
});

class NotificationNotifier extends StateNotifier<bool> {
  final NotificationService _service = NotificationService();

  NotificationNotifier() : super(false);

  Future<void> send(String title, String body) async {
    await _service.showLocalNotification(title, body);
    state = true;
  }
}
