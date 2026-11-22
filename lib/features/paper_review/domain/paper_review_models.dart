class CommentModel {
  final String authorName;
  final String authorRole; // Director, Faculty...
  final String timeText; // "1d ago"
  final String text;

  CommentModel({
    required this.authorName,
    required this.authorRole,
    required this.timeText,
    required this.text,
  });
}

class QuestionModel {
  int number;
  int marks;
  String text;
  String submittedBy;
  String topic;
  List<String> clos; // ["CLO-1", "CLO-2"]
  String difficulty; // Easy, Medium or Hard
  List<CommentModel> comments;

  QuestionModel({
    required this.number,
    required this.marks,
    required this.text,
    required this.submittedBy,
    required this.topic,
    required this.clos,
    required this.difficulty,
    required this.comments,
  });
}

// Everything about one paper that the workspace screen shows.
class PaperDetail {
  final String code;
  final String courseName;
  final String version;
  final String examText; // Final Exam • Fall 2026 • 3 Teachers
  final String submittedBy;
  final int totalMarks;
  final List<QuestionModel> questions;
  final List<QuestionModel> extraQuestions;

  PaperDetail({
    required this.code,
    required this.courseName,
    required this.version,
    required this.examText,
    required this.submittedBy,
    required this.totalMarks,
    required this.questions,
    required this.extraQuestions,
  });
}

// One row of the "Detail" tab: which teacher covered the topic.
class TopicRow {
  final String topic;
  final List<bool> coveredByTeacher; // same order as the teacher names

  TopicRow({required this.topic, required this.coveredByTeacher});

  bool get coveredByAll {
    for (int i = 0; i < coveredByTeacher.length; i++) {
      if (!coveredByTeacher[i]) return false;
    }
    return true;
  }
}

class CoveredTopics {
  final List<String> teacherNames;
  final List<TopicRow> rows;

  CoveredTopics({required this.teacherNames, required this.rows});
}

// One row of the CLO grid.
class CloGridRow {
  final String question; // Q1
  final List<bool> clos; // CLO-1 .. CLO-4
  final bool valid;

  CloGridRow({required this.question, required this.clos, required this.valid});
}

class SimilarityMatch {
  final String title; // Spring 2026 · Final Exam
  final String code; // CS-301
  final String questionsText; // Current questions: Q1, Q2, Q3
  final int percent;

  SimilarityMatch({
    required this.title,
    required this.code,
    required this.questionsText,
    required this.percent,
  });
}
