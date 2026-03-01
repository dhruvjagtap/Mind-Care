import 'smart_calendar_service.dart';
import 'smart_calendar_model.dart';

class SmartCalendarRepository {
  final SmartCalendarService _service = SmartCalendarService();

  Stream<List<CalendarEvent>> fetchEvents() => _service.getEvents();

  Future<void> addEvent(CalendarEvent event) => _service.addEvent(event);

  Future<void> updateEvent(CalendarEvent event) => _service.updateEvent(event);

  Future<void> deleteEvent(String id) => _service.deleteEvent(id);
}
