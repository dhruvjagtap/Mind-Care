class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // "chat", "resource", "mood", etc.
  final String? senderId; // for chat notifications
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.senderId,
    required this.timestamp,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'],
      body: map['body'],
      type: map['type'],
      senderId: map['senderId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'senderId': senderId,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
