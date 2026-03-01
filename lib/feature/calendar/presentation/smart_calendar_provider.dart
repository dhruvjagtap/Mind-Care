import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/smart_calendar_repository.dart';
import '../data/smart_calendar_model.dart';

final smartCalendarRepositoryProvider = Provider(
  (ref) => SmartCalendarRepository(),
);

final calendarEventsProvider = StreamProvider<List<CalendarEvent>>((ref) {
  return ref.watch(smartCalendarRepositoryProvider).fetchEvents();
});
