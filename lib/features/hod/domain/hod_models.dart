class HodStats {
  final int needReview; // submitted papers that need the CLO review
  final int total;
  final int notSubmitted;

  HodStats({
    required this.needReview,
    required this.total,
    required this.notSubmitted,
  });
}

// A course the HOD assigns to a teacher and sets the CLOs for.
class HodCourse {
  final String code;
  final String name;
  final int semester;
  DateTime? dueDate;
  String? teacher;
  String? clos; // "CLO-1, CLO-2"

  HodCourse({
    required this.code,
    required this.name,
    required this.semester,
    this.dueDate,
    this.teacher,
    this.clos,
  });

  bool get isAssigned => dueDate != null && teacher != null;
}
