import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../calendar/data/smart_calendar_model.dart';

class SmartCalendarService {
  Future<CollectionReference<Map<String, dynamic>>?>
  _getUserCalendarRef() async {
    final prefs = await SharedPreferences.getInstance();
    final college = prefs.getString("college");
    final prn = prefs.getString("prn");

    if (college == null || prn == null) return null;

    return FirebaseFirestore.instance
        .collection("colleges")
        .doc(college)
        .collection("students")
        .doc(prn)
        .collection("calendarEvents");
  }

  Future<void> addEvent(CalendarEvent event) async {
    final ref = await _getUserCalendarRef();
    if (ref != null) {
      await ref.add(event.toMap());
    }
  }

  Future<void> updateEvent(CalendarEvent event) async {
    final ref = await _getUserCalendarRef();
    if (ref != null) {
      await ref.doc(event.id).update(event.toMap());
    }
  }

  Future<void> deleteEvent(String id) async {
    final ref = await _getUserCalendarRef();
    if (ref != null) {
      await ref.doc(id).delete();
    }
  }

  Stream<List<CalendarEvent>> getEvents() async* {
    final ref = await _getUserCalendarRef();
    if (ref != null) {
      yield* ref.snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => CalendarEvent.fromMap(doc.data(), doc.id))
            .toList(),
      );
    } else {
      yield [];
    }
  }
}
