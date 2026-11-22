// status is: toReview, approved, notSubmitted or rejected
class DirectorPaper {
  final String code;
  final String courseName;
  final String status;
  final String teacher;
  final String dateText; // "2 days ago", "Oct 24, 2026"
  final String session;
  final String exam;
  final bool isArchived;

  DirectorPaper({
    required this.code,
    required this.courseName,
    required this.status,
    required this.teacher,
    required this.dateText,
    required this.session,
    required this.exam,
    required this.isArchived,
  });
}

class DirectorStats {
  final int total;
  final int submitted;
  final int notSubmitted;
  final int approved;

  DirectorStats({
    required this.total,
    required this.submitted,
    required this.notSubmitted,
    required this.approved,
  });
}

class CourseModel {
  final String code;
  final String name;
  final String department; // CS, SE or AI
  final List<String> teachers;

  CourseModel({
    required this.code,
    required this.name,
    required this.department,
    required this.teachers,
  });
}
