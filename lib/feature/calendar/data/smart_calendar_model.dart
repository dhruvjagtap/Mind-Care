class CalendarEvent {
  final String id;
  final String college;
  final String prn;
  final String title;
  final DateTime date;
  final String type; // exam, submission, reminder
  final String? stressTip;

  CalendarEvent({
    required this.id,
    required this.college,
    required this.prn,
    required this.title,
    required this.date,
    required this.type,
    this.stressTip,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> data, String id) {
    return CalendarEvent(
      id: id,
      college: data['college'] ?? '',
      prn: data['prn'] ?? '',
      title: data['title'] ?? '',
      date: DateTime.parse(data['date']),
      type: data['type'] ?? 'reminder',
      stressTip: data['stressTip'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'college': college,
      'prn': prn,
      'title': title,
      'date': date.toIso8601String(),
      'type': type,
      'stressTip': stressTip,
    };
  }
}
