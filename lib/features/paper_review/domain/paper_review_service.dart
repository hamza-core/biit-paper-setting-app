import '../data/paper_review_repository.dart';
import 'paper_review_models.dart';

// Layer 2 (domain). Rules for the paper review screens.
class PaperReviewService {
  final PaperReviewRepository _repository = PaperReviewRepository();

  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> cloChoices = [
    'CLO-1',
    'CLO-2',
    'CLO-3',
    'CLO-4',
    'CLO-1, CLO-2',
    'CLO-2, CLO-3',
    'CLO-1, CLO-2, CLO-3',
  ];

  Future<PaperDetail> getPaper({
    required String code,
    required String courseName,
    required String submittedBy,
  }) {
    return _repository.getPaper(
      code: code,
      courseName: courseName,
      submittedBy: submittedBy,
    );
  }

  Future<List<String>> getTopics() {
    return _repository.getTopics();
  }

  Future<CoveredTopics> getCoveredTopics(String code) {
    return _repository.getCoveredTopics(code);
  }

  Future<List<SimilarityMatch>> getSimilarity(String code) {
    return _repository.getSimilarity(code);
  }

  int usedMarks(PaperDetail paper) {
    int total = 0;
    for (int i = 0; i < paper.questions.length; i++) {
      total = total + paper.questions[i].marks;
    }
    return total;
  }

  // Checks the form of the edit screen. Returns an error text or null.
  String? validateQuestion(String text, String marksText) {
    if (text.trim().isEmpty) return 'Please write the question';
    int? marks = int.tryParse(marksText.trim());
    if (marks == null || marks <= 0) return 'Marks must be a number above 0';
    return null;
  }

  Future<void> saveQuestion(
    PaperDetail paper,
    QuestionModel question,
    bool isExtra,
  ) {
    return _repository.saveQuestion(paper, question, isExtra);
  }

  Future<void> deleteQuestion(
    PaperDetail paper,
    QuestionModel question,
    bool isExtra,
  ) {
    return _repository.deleteQuestion(paper, question, isExtra);
  }

  // A copy of the question that goes to the end of the list.
  QuestionModel copyQuestion(PaperDetail paper, QuestionModel question) {
    return QuestionModel(
      number: paper.questions.length + 1,
      marks: question.marks,
      text: question.text,
      submittedBy: question.submittedBy,
      topic: question.topic,
      clos: List<String>.from(question.clos),
      difficulty: question.difficulty,
      comments: [],
    );
  }

  void addComment(
    QuestionModel question,
    String text,
    String name,
    String role,
  ) {
    if (text.trim().isEmpty) return;
    question.comments.add(
      CommentModel(
        authorName: name,
        authorRole: role,
        timeText: 'Just now',
        text: text.trim(),
      ),
    );
  }

  // Rows of the CLO grid: which CLOs each question covers.
  List<CloGridRow> cloGrid(PaperDetail paper) {
    List<CloGridRow> rows = [];
    for (int i = 0; i < paper.questions.length; i++) {
      QuestionModel q = paper.questions[i];
      List<bool> clos = [];
      for (int c = 1; c <= 4; c++) {
        clos.add(q.clos.contains('CLO-$c'));
      }
      rows.add(
        CloGridRow(
          question: 'Q${q.number}',
          clos: clos,
          valid: q.clos.isNotEmpty,
        ),
      );
    }
    return rows;
  }

  // Returns an error text when the decision cannot be confirmed.
  String? validateDecision(bool approve, String comment) {
    if (!approve && comment.trim().isEmpty) {
      return 'Please add a comment to reject the paper';
    }
    return null;
  }

  String initials(String name) {
    List<String> words = name.split(' ');
    String result = '';
    for (int i = 0; i < words.length; i++) {
      if (words[i].isEmpty || words[i].endsWith('.')) continue;
      result = result + words[i][0].toUpperCase();
      if (result.length == 2) break;
    }
    return result;
  }
}
