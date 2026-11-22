import '../domain/import_models.dart';
import '../domain/paper_model.dart';
import '../domain/stats_model.dart';

// Layer 3 (data). Everything comes from lists for now.
// Later each method will call the API instead.
class DatacellRepository {
  static const int _total = 24;
  static int _submitted = 18;
  static int _notSubmitted = 6;

  static final List<PaperModel> _papers = [
    PaperModel(
      code: 'CC-301',
      version: 'v1',
      courseName: 'Data Structures',
      session: 'Fall 2026',
      exam: 'Final',
      submittedBy: 'Dr. Saeed Iqbal',
      isSubmitted: true,
    ),
    PaperModel(
      code: 'CC-401',
      version: 'v1',
      courseName: 'Compiler Construction',
      session: 'Fall 2026',
      exam: 'Final',
      submittedBy: 'Dr. Saeed Iqbal',
      isSubmitted: true,
    ),
    PaperModel(
      code: 'CC-301',
      version: 'v1',
      courseName: 'Data Structures',
      session: 'Fall 2026',
      exam: 'Final',
      submittedBy: 'Dr. Saeed Iqbal',
      isSubmitted: false,
    ),
    PaperModel(
      code: 'CS-302',
      version: 'v1',
      courseName: 'Database',
      session: 'Fall 2026',
      exam: 'Mid',
      submittedBy: 'Mr. Amir Rasheed',
      isSubmitted: true,
    ),
    PaperModel(
      code: 'CS-303',
      version: 'v1',
      courseName: 'Operating Systems',
      session: 'Spring 2026',
      exam: 'Final',
      submittedBy: 'Mr. Afrasiab Kaikobad',
      isSubmitted: false,
    ),
  ];

  Future<StatsModel> getStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return StatsModel(
      total: _total,
      submitted: _submitted,
      notSubmitted: _notSubmitted,
    );
  }

  Future<List<PaperModel>> getPapers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _papers;
  }

  Future<void> submitPaper(PaperModel paper) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!paper.isSubmitted) {
      paper.isSubmitted = true;
      _submitted = _submitted + 1;
      _notSubmitted = _notSubmitted - 1;
    }
  }

  // The real file picker will come later. For now we pretend
  // the user chose this file.
  Future<String> pickFile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'data-file.xlsx';
  }

  Future<List<ImportRow>> readImportFile(String fileName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ImportRow(
        type: 'teacher',
        id: 'T-902',
        name: 'Azhar Jamil',
        detail: 'AI',
      ),
      ImportRow(
        type: 'teacher',
        id: 'T-401',
        name: 'Prof Dr. Mohsin Raza',
        detail: 'PBS',
      ),
      ImportRow(
        type: 'teacher',
        id: 'T-102',
        name: 'Dr. Saeed Iqbal',
        detail: 'DSA, CS',
      ),
      ImportRow(
        type: 'course',
        id: 'CS-301',
        name: 'Data Structures',
        detail: 'Computer Science',
      ),
      ImportRow(
        type: 'course',
        id: 'CC-401',
        name: 'Compiler Construction',
        detail: 'Computer Science',
      ),
      ImportRow(
        type: 'course',
        id: 'CS-302',
        name: 'Database',
        detail: 'Computer Science',
      ),
      ImportRow(
        type: 'course',
        id: 'CS-303',
        name: 'Operating Systems',
        detail: 'Computer Science',
      ),
      ImportRow(
        type: 'department',
        id: 'D-01',
        name: 'Computer Science',
        detail: 'Dr. Munir Ahmad',
      ),
      ImportRow(
        type: 'department',
        id: 'D-02',
        name: 'Software Engineering',
        detail: 'Dr. Saeed Iqbal',
      ),
      ImportRow(
        type: 'department',
        id: 'D-03',
        name: 'Information Technology',
        detail: 'Azhar Jamil',
      ),
      ImportRow(
        type: 'account',
        id: 'A-01',
        name: 'azhar@biit.edu.pk',
        detail: 'Faculty',
      ),
    ];
  }

  Future<void> saveImport(List<ImportRow> rows) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Later: send the rows to the API. Nothing to store for now.
  }
}
