import '../domain/faculty_models.dart';

// Layer 3 (data). Lists for now, the API later.
class FacultyRepository {
  final List<FacultyCourse> _courses = [
    FacultyCourse(
      code: 'CS-301',
      name: 'Data Structures',
      status: 'changesRequired',
      dueText: 'Oct 24, 2026',
      examText: 'Final Exam • Fall 2026',
      teachers: [
        TeacherStatus(name: 'Mr. Amir Rasheed', marked: true),
        TeacherStatus(name: 'Dr. Saeed Iqbal', marked: true),
        TeacherStatus(name: 'Mr. Afrasiab Kaikobad', marked: false),
      ],
    ),
    FacultyCourse(
      code: 'CS-302',
      name: 'Database',
      status: 'paperToSet',
      dueText: 'Oct 30, 2026',
      examText: 'Final Exam • Fall 2026',
      teachers: [TeacherStatus(name: 'Mr. Amir Rasheed', marked: true)],
    ),
    FacultyCourse(
      code: 'CS-303',
      name: 'Operating Systems',
      status: 'questionsToAdd',
      dueText: 'Nov 02, 2026',
      examText: 'Final Exam • Fall 2026',
      teachers: [
        TeacherStatus(name: 'Mr. Amir Rasheed', marked: true),
        TeacherStatus(name: 'Dr. Saeed Iqbal', marked: false),
      ],
    ),
  ];

  final List<ArchivedPaper> _archive = [
    ArchivedPaper(
      code: 'CS-201',
      name: 'Programming Fundamentals',
      result: 'approved',
      session: 'Fall 2026',
      exam: 'Final',
    ),
    ArchivedPaper(
      code: 'CS-205',
      name: 'Discrete Mathematics',
      result: 'approved',
      session: 'Fall 2026',
      exam: 'Final',
    ),
    ArchivedPaper(
      code: 'HU-112',
      name: 'Technical Writing',
      result: 'rejected',
      session: 'Fall 2026',
      exam: 'Final',
    ),
    ArchivedPaper(
      code: 'CS-210',
      name: 'Computer Networks',
      result: 'approved',
      session: 'Spring 2026',
      exam: 'Mid',
    ),
  ];

  Future<List<FacultyCourse>> getCourses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _courses;
  }

  Future<List<ArchivedPaper>> getArchive() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _archive;
  }
}
