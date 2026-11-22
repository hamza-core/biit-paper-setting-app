class PaperModel {
  final String code; // CC-301
  final String version; // v1
  final String courseName;
  final String session; // Fall 2026
  final String exam; // Final
  final String submittedBy;
  bool isSubmitted;

  PaperModel({
    required this.code,
    required this.version,
    required this.courseName,
    required this.session,
    required this.exam,
    required this.submittedBy,
    required this.isSubmitted,
  });
}
