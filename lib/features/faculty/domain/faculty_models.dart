// status is: changesRequired, paperToSet or questionsToAdd
class FacultyCourse {
  final String code;
  final String name;
  final String status;
  final String dueText; // Oct 24, 2026
  final String examText; // Final Exam • Fall 2026
  final List<TeacherStatus> teachers;

  FacultyCourse({
    required this.code,
    required this.name,
    required this.status,
    required this.dueText,
    required this.examText,
    required this.teachers,
  });
}

class TeacherStatus {
  final String name;
  final bool marked; // true = marked their topics, false = pending

  TeacherStatus({required this.name, required this.marked});
}

class FacultyStats {
  final int courses;
  final int papersToSet;

  FacultyStats({required this.courses, required this.papersToSet});
}

// A paper of a past session. result is approved or rejected.
class ArchivedPaper {
  final String code;
  final String name;
  final String result;
  final String session;
  final String exam;

  ArchivedPaper({
    required this.code,
    required this.name,
    required this.result,
    required this.session,
    required this.exam,
  });
}
