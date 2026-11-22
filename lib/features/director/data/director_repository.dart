import '../domain/director_models.dart';

// Layer 3 (data). Lists for now, the API later.
class DirectorRepository {
  static final List<DirectorPaper> _papers = [
    DirectorPaper(
      code: 'CC-401',
      courseName: 'Compiler Construction',
      status: 'toReview',
      teacher: 'Nauman Iqbal',
      dateText: '2 days ago',
      session: 'Fall 2026',
      exam: 'Final',
      isArchived: false,
    ),
    DirectorPaper(
      code: 'CS-301',
      courseName: 'Data Structures',
      status: 'approved',
      teacher: 'Dr. Munir Ahmed',
      dateText: 'Oct 24, 2026',
      session: 'Fall 2026',
      exam: 'Final',
      isArchived: false,
    ),
    DirectorPaper(
      code: 'AI-401',
      courseName: 'Artificial Intelligence',
      status: 'notSubmitted',
      teacher: 'Dr. Sadaf Gul',
      dateText: 'Oct 24, 2026',
      session: 'Fall 2026',
      exam: 'Final',
      isArchived: false,
    ),
    DirectorPaper(
      code: 'CS-201',
      courseName: 'Programming Fundamentals',
      status: 'approved',
      teacher: 'Aftab Khan',
      dateText: 'Jun 12, 2026',
      session: 'Fall 2026',
      exam: 'Final',
      isArchived: true,
    ),
    DirectorPaper(
      code: 'EW-112',
      courseName: 'Expository Writing',
      status: 'rejected',
      teacher: 'Khalid Mehmood',
      dateText: 'Jun 10, 2026',
      session: 'Fall 2026',
      exam: 'Final',
      isArchived: true,
    ),
    DirectorPaper(
      code: 'CS-205',
      courseName: 'Discrete Mathematics',
      status: 'approved',
      teacher: 'Mr. Amir Rasheed',
      dateText: 'Jun 08, 2026',
      session: 'Fall 2026',
      exam: 'Final',
      isArchived: true,
    ),
    DirectorPaper(
      code: 'CS-210',
      courseName: 'Operating Systems',
      status: 'approved',
      teacher: 'Dr. Saeed Iqbal',
      dateText: 'Feb 20, 2026',
      session: 'Spring 2026',
      exam: 'Mid',
      isArchived: true,
    ),
  ];

  final List<CourseModel> _courses = [
    CourseModel(
      code: 'CS-201',
      name: 'Data Structures',
      department: 'CS',
      teachers: [
        'Mr. Amir Rasheed',
        'Dr. Saeed Iqbal',
        'Afrasiab Kaikobad',
        'Nauman Iqbal',
      ],
    ),
    CourseModel(
      code: 'CC-401',
      name: 'Compiler Construction',
      department: 'CS',
      teachers: ['Nauman Iqbal', 'Dr. Munir Ahmed'],
    ),
    CourseModel(
      code: 'CS-302',
      name: 'Database Systems',
      department: 'CS',
      teachers: ['Dr. Saeed Iqbal'],
    ),
    CourseModel(
      code: 'CS-303',
      name: 'Software Engineering',
      department: 'SE',
      teachers: ['Dr. Sadaf Gul'],
    ),
  ];

  Future<DirectorStats> getStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DirectorStats(
      total: 60,
      submitted: 50,
      notSubmitted: 10,
      approved: 1,
    );
  }

  Future<List<DirectorPaper>> getPapers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _papers;
  }

  Future<void> sendReminder(DirectorPaper paper) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Later: call the API to send the reminder.
  }

  Future<List<CourseModel>> getCourses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _courses;
  }
}
