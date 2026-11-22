import '../domain/paper_review_models.dart';

// Layer 3 (data). Lists for now, the API later.
class PaperReviewRepository {
  // Papers that were already opened (so edits are kept).
  static final Map<String, PaperDetail> _papers = {};

  Future<PaperDetail> getPaper({
    required String code,
    required String courseName,
    required String submittedBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_papers.containsKey(code)) {
      _papers[code] = _samplePaper(code, courseName, submittedBy);
    }
    return _papers[code]!;
  }

  PaperDetail _samplePaper(String code, String courseName, String submittedBy) {
    return PaperDetail(
      code: code,
      courseName: courseName,
      version: 'v1',
      examText: 'Final Exam • Fall 2026 • 3 Teachers',
      submittedBy: submittedBy,
      totalMarks: 60,
      questions: [
        QuestionModel(
          number: 1,
          marks: 10,
          text: 'Explain the phases of a compiler with a block diagram. Describe what each phase does using the expression: a = b + c * 5.',
          submittedBy: 'Dr. Saeed Iqbal',
          topic: 'Compiler Phases',
          clos: ['CLO-1'],
          difficulty: 'Medium',
          comments: [
            CommentModel(
              authorName: 'Dr. Jameel Sawar',
              authorRole: 'Director',
              timeText: '1d ago',
              text: 'Noted. Please also add labels to all transitions for clarity.',
            ),
          ],
        ),
        QuestionModel(
          number: 2,
          marks: 12,
          text: 'Construct a DFA from the regular expression (a|b)*abb. Show the NFA first, then convert it to a DFA using subset construction.',
          submittedBy: 'Mr. Amir Rasheed',
          topic: 'Finite Automata',
          clos: ['CLO-1', 'CLO-2'],
          difficulty: 'Hard',
          comments: [],
        ),
        QuestionModel(
          number: 3,
          marks: 8,
          text: 'Differentiate between a lexeme, a token and a pattern with examples.',
          submittedBy: 'Dr. Saeed Iqbal',
          topic: 'Regular Expressions',
          clos: ['CLO-2'],
          difficulty: 'Easy',
          comments: [],
        ),
      ],
      extraQuestions: [
        QuestionModel(
          number: 1,
          marks: 12,
          text: 'Linked Lists: What is the primary structural advantage of a Linked List over a static Array?',
          submittedBy: 'Dr. Saeed Iqbal',
          topic: 'Syntax Analysis',
          clos: ['CLO-1'],
          difficulty: 'Medium',
          comments: [],
        ),
      ],
    );
  }

  Future<void> saveQuestion(
    PaperDetail paper,
    QuestionModel question,
    bool isExtra,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    List<QuestionModel> list = isExtra ? paper.extraQuestions : paper.questions;
    if (!list.contains(question)) {
      list.add(question);
    }
  }

  Future<void> deleteQuestion(
    PaperDetail paper,
    QuestionModel question,
    bool isExtra,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    List<QuestionModel> list = isExtra ? paper.extraQuestions : paper.questions;
    list.remove(question);
    for (int i = 0; i < list.length; i++) {
      list[i].number = i + 1;
    }
  }

  Future<CoveredTopics> getCoveredTopics(String code) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return CoveredTopics(
      teacherNames: ['Saeed Iqbal', 'Amir Rasheed'],
      rows: [
        TopicRow(topic: 'Lexical Analysis', coveredByTeacher: [true, false]),
        TopicRow(topic: 'Regular Expressions', coveredByTeacher: [true, true]),
        TopicRow(topic: 'NFA & DFA', coveredByTeacher: [false, true]),
        TopicRow(topic: 'Syntax Analysis', coveredByTeacher: [true, true]),
        TopicRow(topic: 'Semantic Analysis', coveredByTeacher: [false, false]),
      ],
    );
  }

  Future<List<SimilarityMatch>> getSimilarity(String code) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      SimilarityMatch(
        title: 'Spring 2026 · Final Exam',
        code: code,
        questionsText: 'Current questions: Q1, Q2, Q3',
        percent: 75,
      ),
      SimilarityMatch(
        title: 'Spring 2025 · Mid Term',
        code: code,
        questionsText: 'Current question: Q4',
        percent: 25,
      ),
    ];
  }

  Future<List<String>> getTopics() async {
    return [
      'Compiler Phases',
      'Finite Automata',
      'Regular Expressions',
      'Syntax Analysis',
    ];
  }
}
