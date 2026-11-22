import '../domain/hod_models.dart';

// Layer 3 (data). Lists for now, the API later.
class HodRepository {
  static final List<HodCourse> _courses = [
    HodCourse(code: 'CS-301', name: 'Data Structures', semester: 3),
    HodCourse(
      code: 'CS-302',
      name: 'Compiler Construction',
      semester: 3,
      dueDate: DateTime(2026, 10, 24),
      teacher: 'Dr. Saeed Iqbal',
      clos: 'CLO-1, CLO-2',
    ),
    HodCourse(code: 'CS-101', name: 'Programming Fundamentals', semester: 1),
    HodCourse(code: 'MT-102', name: 'Calculus', semester: 1),
    HodCourse(code: 'CS-201', name: 'Object Oriented Programming', semester: 2),
    HodCourse(code: 'CS-205', name: 'Discrete Mathematics', semester: 2),
    HodCourse(code: 'CS-303', name: 'Operating Systems', semester: 3),
  ];

  final List<String> _teachers = [
    'Dr. Saeed Iqbal',
    'Mr. Amir Rasheed',
    'Afrasiab Kaikobad',
    'Nauman Iqbal',
    'Dr. Sadaf Gul',
  ];

  Future<HodStats> getStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return HodStats(needReview: 5, total: 60, notSubmitted: 55);
  }

  Future<List<HodCourse>> getCourses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _courses;
  }

  Future<List<String>> getTeachers() async {
    return _teachers;
  }

  Future<void> assignPaper(
    HodCourse course,
    DateTime date,
    String teacher,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Later: send the assignment to the API.
    course.dueDate = date;
    course.teacher = teacher;
  }

  Future<void> setClos(List<HodCourse> courses, String clos) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < courses.length; i++) {
      courses[i].clos = clos;
    }
  }
}
