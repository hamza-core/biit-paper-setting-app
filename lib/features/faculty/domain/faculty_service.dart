import '../data/faculty_repository.dart';
import 'faculty_models.dart';

// Layer 2 (domain). Rules for the faculty screens.
class FacultyService {
  final FacultyRepository _repository = FacultyRepository();

  final List<String> sessions = ['Fall 2026', 'Spring 2026'];
  final List<String> exams = ['Final', 'Mid'];

  Future<FacultyStats> getStats() async {
    List<FacultyCourse> courses = await _repository.getCourses();
    int toSet = 0;
    for (int i = 0; i < courses.length; i++) {
      if (courses[i].status != 'changesRequired') toSet = toSet + 1;
    }
    return FacultyStats(courses: courses.length, papersToSet: toSet);
  }

  Future<List<FacultyCourse>> getCourses({String search = ''}) async {
    List<FacultyCourse> all = await _repository.getCourses();
    String text = search.trim().toLowerCase();
    if (text.isEmpty) return all;

    List<FacultyCourse> result = [];
    for (int i = 0; i < all.length; i++) {
      if (all[i].name.toLowerCase().contains(text) ||
          all[i].code.toLowerCase().contains(text)) {
        result.add(all[i]);
      }
    }
    return result;
  }

  // tab is: all, approved or rejected
  Future<List<ArchivedPaper>> getArchive({
    required String tab,
    String search = '',
    String? session,
    String? exam,
  }) async {
    List<ArchivedPaper> all = await _repository.getArchive();
    List<ArchivedPaper> result = [];
    String text = search.trim().toLowerCase();

    for (int i = 0; i < all.length; i++) {
      ArchivedPaper paper = all[i];
      if (tab != 'all' && paper.result != tab) continue;
      if (session != null && paper.session != session) continue;
      if (exam != null && paper.exam != exam) continue;
      if (text.isNotEmpty) {
        bool matches =
            paper.name.toLowerCase().contains(text) ||
            paper.code.toLowerCase().contains(text);
        if (!matches) continue;
      }
      result.add(paper);
    }
    return result;
  }

  int markedCount(FacultyCourse course) {
    int count = 0;
    for (int i = 0; i < course.teachers.length; i++) {
      if (course.teachers[i].marked) count = count + 1;
    }
    return count;
  }

  // "2 of 3 teachers marked their topics."
  String markedText(FacultyCourse course) {
    return '${markedCount(course)} of ${course.teachers.length} teachers marked their topics.';
  }

  // "Waiting for 1 teacher." or null when everyone is done.
  String? waitingText(FacultyCourse course) {
    int waiting = course.teachers.length - markedCount(course);
    if (waiting == 0) return null;
    return waiting == 1
        ? 'Waiting for 1 teacher.'
        : 'Waiting for $waiting teachers.';
  }

  String statusText(String status) {
    if (status == 'changesRequired') return 'Changes Required';
    if (status == 'paperToSet') return 'Paper to set';
    return 'Questions to add';
  }
}
