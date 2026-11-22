import '../data/hod_repository.dart';
import 'hod_models.dart';

// Layer 2 (domain). Rules for the HOD screens.
class HodService {
  final HodRepository _repository = HodRepository();

  final List<int> semesters = [1, 2, 3];
  final List<String> sessions = ['Fall 2026', 'Spring 2026'];
  final List<String> exams = ['Final', 'Mid'];
  final List<String> cloChoices = [
    'CLO-1',
    'CLO-2',
    'CLO-3',
    'CLO-4',
    'CLO-1, CLO-2',
    'CLO-2, CLO-3',
    'CLO-1, CLO-2, CLO-3',
    'CLO-1, CLO-2, CLO-3, CLO-4',
  ];

  Future<HodStats> getStats() {
    return _repository.getStats();
  }

  Future<List<String>> getTeachers() {
    return _repository.getTeachers();
  }

  // semester 0 = all semesters
  Future<List<HodCourse>> getCourses({
    String search = '',
    int semester = 0,
  }) async {
    List<HodCourse> all = await _repository.getCourses();
    List<HodCourse> result = [];
    String text = search.trim().toLowerCase();

    for (int i = 0; i < all.length; i++) {
      HodCourse course = all[i];
      if (semester != 0 && course.semester != semester) continue;
      if (text.isNotEmpty) {
        bool matches =
            course.name.toLowerCase().contains(text) ||
            course.code.toLowerCase().contains(text) ||
            (course.teacher ?? '').toLowerCase().contains(text);
        if (!matches) continue;
      }
      result.add(course);
    }
    return result;
  }

  // Throws a message when the date or the teacher is missing.
  Future<void> assignPaper(HodCourse course, DateTime? date, String? teacher) {
    if (date == null) throw 'Please select a date';
    if (teacher == null) throw 'Please select a teacher';
    return _repository.assignPaper(course, date, teacher);
  }

  Future<void> setClos(List<HodCourse> courses, String clos) {
    return _repository.setClos(courses, clos);
  }

  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // "Oct 24, 2026"
  String dateText(DateTime date) {
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
