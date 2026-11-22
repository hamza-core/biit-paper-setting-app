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

  // ---------- Covered topics ----------

  final List<String> _sections = ['Section A', 'Section B'];

  final List<WeekModel> _weeks = [
    WeekModel(
      name: 'Week 1',
      topics: [
        TopicItem(name: 'Arrays and Linked Lists'),
        TopicItem(name: 'Stacks and Queues'),
        TopicItem(
          name: 'Loops',
          subTopics: ['While Loop', 'for Loop', 'do-while Loop'],
        ),
        TopicItem(name: 'Sorting Algorithms'),
        TopicItem(name: 'Hashing and Hash Tables'),
        TopicItem(name: 'Heaps and Priority Queues'),
        TopicItem(name: 'String Algorithms'),
      ],
    ),
    WeekModel(
      name: 'Week 2',
      topics: [
        TopicItem(name: 'Trees'),
        TopicItem(name: 'Binary Search Trees'),
        TopicItem(name: 'Graphs'),
        TopicItem(name: 'Graph Traversals'),
        TopicItem(name: 'Greedy Algorithms'),
      ],
    ),
  ];

  // Saved selections: course code -> section -> selected topic names.
  static final Map<String, Map<String, Set<String>>> _saved = {};

  Future<List<String>> getSections() async {
    return _sections;
  }

  Future<List<WeekModel>> getWeeks(String courseCode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _weeks;
  }

  Future<Map<String, Set<String>>> getSelections(String courseCode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_saved.containsKey(courseCode)) {
      // a copy, so the screen can change it before saving
      Map<String, Set<String>> copy = {};
      _saved[courseCode]!.forEach((section, names) {
        copy[section] = Set<String>.from(names);
      });
      return copy;
    }
    return {
      'Section A': {'Arrays and Linked Lists', 'Stacks and Queues', 'Loops'},
      'Section B': <String>{},
    };
  }

  Future<void> saveSelections(
    FacultyCourse course,
    String teacherName,
    Map<String, Set<String>> selections,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Later: send the marked topics to the API.
    _saved[course.code] = selections;
    for (int i = 0; i < course.teachers.length; i++) {
      if (course.teachers[i].name == teacherName) {
        course.teachers[i].marked = true;
      }
    }
  }
}
