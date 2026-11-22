import '../data/director_repository.dart';
import 'director_models.dart';

// Layer 2 (domain). Rules for the director screens.
class DirectorService {
  final DirectorRepository _repository = DirectorRepository();

  final List<String> sessions = ['Fall 2026', 'Spring 2026'];
  final List<String> exams = ['Final', 'Mid'];
  final List<String> departments = ['All', 'CS', 'SE', 'AI'];

  Future<DirectorStats> getStats() {
    return _repository.getStats();
  }

  // archived = false -> current papers, true -> archived papers.
  // statusFilter: 'all' or one status (toReview, approved, ...).
  Future<List<DirectorPaper>> getPapers({
    required bool archived,
    required String statusFilter,
    String search = '',
    String? session,
    String? exam,
  }) async {
    List<DirectorPaper> all = await _repository.getPapers();
    List<DirectorPaper> result = [];
    String text = search.trim().toLowerCase();

    for (int i = 0; i < all.length; i++) {
      DirectorPaper paper = all[i];
      if (paper.isArchived != archived) continue;
      if (statusFilter != 'all' && paper.status != statusFilter) continue;
      if (session != null && paper.session != session) continue;
      if (exam != null && paper.exam != exam) continue;
      if (text.isNotEmpty) {
        bool matches =
            paper.courseName.toLowerCase().contains(text) ||
            paper.teacher.toLowerCase().contains(text) ||
            paper.code.toLowerCase().contains(text);
        if (!matches) continue;
      }
      result.add(paper);
    }
    return result;
  }

  Future<void> sendReminder(DirectorPaper paper) {
    return _repository.sendReminder(paper);
  }

  Future<List<CourseModel>> getCourses({
    String search = '',
    String department = 'All',
  }) async {
    List<CourseModel> all = await _repository.getCourses();
    List<CourseModel> result = [];
    String text = search.trim().toLowerCase();

    for (int i = 0; i < all.length; i++) {
      CourseModel course = all[i];
      if (department != 'All' && course.department != department) continue;
      if (text.isNotEmpty) {
        bool matches =
            course.name.toLowerCase().contains(text) ||
            course.code.toLowerCase().contains(text);
        if (!matches) continue;
      }
      result.add(course);
    }
    return result;
  }

  // "Mr. Amir Rasheed" -> "AR" (titles that end with a dot are skipped)
  String initials(String name) {
    List<String> words = name.split(' ');
    String result = '';
    for (int i = 0; i < words.length; i++) {
      if (words[i].isEmpty || words[i].endsWith('.')) continue;
      result = result + words[i][0].toUpperCase();
      if (result.length == 2) break;
    }
    return result;
  }
}
