import 'diary_model.dart';
import 'diary_service.dart';

class DiaryRepository {
  final DiaryService _service = DiaryService();

  Future<void> addEntry(DiaryEntry entry) => _service.saveDiaryEntry(entry);

  Stream<List<DiaryEntry>> fetchEntries(String prn) =>
      _service.getDiaryEntries(prn);
}
