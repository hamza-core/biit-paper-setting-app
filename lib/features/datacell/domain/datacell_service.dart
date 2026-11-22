import '../data/datacell_repository.dart';
import 'import_models.dart';
import 'paper_model.dart';
import 'stats_model.dart';

// Layer 2 (domain). Rules for the datacell screens.
class DatacellService {
  final DatacellRepository _repository = DatacellRepository();

  final List<String> sessions = ['Fall 2026', 'Spring 2026'];
  final List<String> exams = ['Final', 'Mid'];

  Future<StatsModel> getStats() {
    return _repository.getStats();
  }

  // tab is: all, submitted or notSubmitted
  Future<List<PaperModel>> getPapers({
    required String tab,
    required String search,
    required String session,
    required String exam,
  }) async {
    List<PaperModel> all = await _repository.getPapers();
    List<PaperModel> result = [];
    String text = search.trim().toLowerCase();

    for (int i = 0; i < all.length; i++) {
      PaperModel paper = all[i];
      if (paper.session != session || paper.exam != exam) continue;
      if (tab == 'submitted' && !paper.isSubmitted) continue;
      if (tab == 'notSubmitted' && paper.isSubmitted) continue;
      if (text.isNotEmpty) {
        bool matches =
            paper.courseName.toLowerCase().contains(text) ||
            paper.code.toLowerCase().contains(text);
        if (!matches) continue;
      }
      result.add(paper);
    }
    return result;
  }

  Future<void> submitPaper(PaperModel paper) {
    return _repository.submitPaper(paper);
  }

  Future<String> pickFile() {
    return _repository.pickFile();
  }

  Future<List<ImportRow>> readImportFile(String fileName) async {
    if (!fileName.endsWith('.xlsx')) {
      throw 'Please choose an .xlsx file';
    }
    return _repository.readImportFile(fileName);
  }

  int countRows(List<ImportRow> rows, String type) {
    int count = 0;
    for (int i = 0; i < rows.length; i++) {
      if (rows[i].type == type) count = count + 1;
    }
    return count;
  }

  Future<ImportSummary> confirmImport(List<ImportRow> rows) async {
    if (rows.isEmpty) {
      throw 'There is no data to import';
    }
    await _repository.saveImport(rows);
    return ImportSummary(
      teachers: countRows(rows, 'teacher'),
      courses: countRows(rows, 'course'),
      departments: countRows(rows, 'department'),
    );
  }
}
