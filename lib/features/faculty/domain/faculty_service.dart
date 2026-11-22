import '../../paper_review/domain/paper_review_models.dart';
import '../data/faculty_repository.dart';
import 'faculty_models.dart';

// Layer 2 (domain). Rules for the faculty screens.
class FacultyService {
  final FacultyRepository _repository = FacultyRepository();

  final List<String> sessions = ['Fall 2026', 'Spring 2026'];
  final List<String> exams = ['Final', 'Mid'];

  Future<FacultyStats> getStats() async {
    List<FacultyCourse> courses = await _repository.getCourses();
    int toSet = 0;
    for (int i = 0; i < courses.length; i++) {
      if (courses[i].status != 'changesRequired') toSet = toSet + 1;
    }
    return FacultyStats(courses: courses.length, papersToSet: toSet);
  }

  Future<List<FacultyCourse>> getCourses({String search = ''}) async {
    List<FacultyCourse> all = await _repository.getCourses();
    String text = search.trim().toLowerCase();
    if (text.isEmpty) return all;

    List<FacultyCourse> result = [];
    for (int i = 0; i < all.length; i++) {
      if (all[i].name.toLowerCase().contains(text) ||
          all[i].code.toLowerCase().contains(text)) {
        result.add(all[i]);
      }
    }
    return result;
  }

  // tab is: all, approved or rejected
  Future<List<ArchivedPaper>> getArchive({
    required String tab,
    String search = '',
    String? session,
    String? exam,
  }) async {
    List<ArchivedPaper> all = await _repository.getArchive();
    List<ArchivedPaper> result = [];
    String text = search.trim().toLowerCase();

    for (int i = 0; i < all.length; i++) {
      ArchivedPaper paper = all[i];
      if (tab != 'all' && paper.result != tab) continue;
      if (session != null && paper.session != session) continue;
      if (exam != null && paper.exam != exam) continue;
      if (text.isNotEmpty) {
        bool matches =
            paper.name.toLowerCase().contains(text) ||
            paper.code.toLowerCase().contains(text);
        if (!matches) continue;
      }
      result.add(paper);
    }
    return result;
  }

  int markedCount(FacultyCourse course) {
    int count = 0;
    for (int i = 0; i < course.teachers.length; i++) {
      if (course.teachers[i].marked) count = count + 1;
    }
    return count;
  }

  // "2 of 3 teachers marked their topics."
  String markedText(FacultyCourse course) {
    return '${markedCount(course)} of ${course.teachers.length} teachers marked their topics.';
  }

  // "Waiting for 1 teacher." or null when everyone is done.
  String? waitingText(FacultyCourse course) {
    int waiting = course.teachers.length - markedCount(course);
    if (waiting == 0) return null;
    return waiting == 1
        ? 'Waiting for 1 teacher.'
        : 'Waiting for $waiting teachers.';
  }

  String statusText(String status) {
    if (status == 'changesRequired') return 'Changes Required';
    if (status == 'paperToSet') return 'Paper to set';
    return 'Questions to add';
  }

  // ---------- Covered topics ----------

  Future<List<String>> getSections() {
    return _repository.getSections();
  }

  Future<List<WeekModel>> getWeeks(String courseCode) {
    return _repository.getWeeks(courseCode);
  }

  Future<Map<String, Set<String>>> getSelections(String courseCode) {
    return _repository.getSelections(courseCode);
  }

  int totalTopics(List<WeekModel> weeks) {
    int total = 0;
    for (int i = 0; i < weeks.length; i++) {
      total = total + weeks[i].topics.length;
    }
    return total;
  }

  // 0 = none selected, 1 = some, 2 = all (for a week or for all weeks)
  int weekState(WeekModel week, Set<String> selected) {
    int count = 0;
    for (int i = 0; i < week.topics.length; i++) {
      if (selected.contains(week.topics[i].name)) count = count + 1;
    }
    if (count == 0) return 0;
    return count == week.topics.length ? 2 : 1;
  }

  int allState(List<WeekModel> weeks, Set<String> selected) {
    int total = totalTopics(weeks);
    if (selected.isEmpty) return 0;
    return selected.length == total ? 2 : 1;
  }

  // Selects or clears a whole week. Returns the new set.
  void toggleWeek(WeekModel week, Set<String> selected) {
    bool selectAll = weekState(week, selected) != 2;
    for (int i = 0; i < week.topics.length; i++) {
      if (selectAll) {
        selected.add(week.topics[i].name);
      } else {
        selected.remove(week.topics[i].name);
      }
    }
  }

  void toggleAll(List<WeekModel> weeks, Set<String> selected) {
    bool selectAll = allState(weeks, selected) != 2;
    for (int i = 0; i < weeks.length; i++) {
      for (int t = 0; t < weeks[i].topics.length; t++) {
        if (selectAll) {
          selected.add(weeks[i].topics[t].name);
        } else {
          selected.remove(weeks[i].topics[t].name);
        }
      }
    }
  }

  void toggleTopic(String name, Set<String> selected) {
    if (selected.contains(name)) {
      selected.remove(name);
    } else {
      selected.add(name);
    }
  }

  // Throws a message when nothing is selected in any section.
  Future<void> submitTopics(
    FacultyCourse course,
    String teacherName,
    Map<String, Set<String>> selections,
  ) {
    bool any = false;
    selections.forEach((section, names) {
      if (names.isNotEmpty) any = true;
    });
    if (!any) throw 'Please mark at least one topic';
    return _repository.saveSelections(course, teacherName, selections);
  }

  // ---------- Paper workspace ----------

  Future<PaperDetail> getPaper(FacultyCourse course, String teacherName) {
    return _repository.getPaper(course, teacherName);
  }

  int usedMarks(PaperDetail paper) {
    int total = 0;
    for (int i = 0; i < paper.questions.length; i++) {
      if (paper.questions[i].isWritten) {
        total = total + paper.questions[i].marks;
      }
    }
    return total;
  }

  // Returns an error text, or null when the number is fine.
  String? validateTotalMarks(PaperDetail paper, String text) {
    int? marks = int.tryParse(text.trim());
    if (marks == null || marks <= 0) {
      return 'Total marks must be a number above 0';
    }
    if (marks < usedMarks(paper)) {
      return 'Total marks cannot be less than the marks already used';
    }
    return null;
  }

  // A new empty question that the teacher can write or give to someone.
  QuestionModel newBlankQuestion(List<QuestionModel> list, String teacherName) {
    return QuestionModel(
      number: list.length + 1,
      marks: 5,
      text: '',
      submittedBy: teacherName,
      topic: 'Compiler Phases',
      clos: ['CLO-1'],
      difficulty: 'Medium',
      comments: [],
    );
  }

  void renumber(List<QuestionModel> list) {
    for (int i = 0; i < list.length; i++) {
      list[i].number = i + 1;
    }
  }

  // Moves an extra question to the end of the full paper.
  void moveToPaper(PaperDetail paper, QuestionModel question) {
    paper.extraQuestions.remove(question);
    paper.questions.add(question);
    renumber(paper.extraQuestions);
    renumber(paper.questions);
  }

  // Deleting puts the question in the trash, it can be restored.
  void moveToTrash(PaperDetail paper, QuestionModel question) {
    paper.questions.remove(question);
    paper.extraQuestions.remove(question);
    paper.trash.add(question);
    renumber(paper.questions);
    renumber(paper.extraQuestions);
  }

  // Returns an error text, or null when the paper can be submitted.
  String? validateSubmit(PaperDetail paper) {
    if (paper.questions.isEmpty) return 'Add at least one question first';
    for (int i = 0; i < paper.questions.length; i++) {
      if (!paper.questions[i].isWritten) {
        return 'Q${paper.questions[i].number} is not written yet';
      }
    }
    if (usedMarks(paper) > paper.totalMarks) {
      return 'The questions have more marks than the total marks';
    }
    return null;
  }

  Future<void> submitPaper(PaperDetail paper) async {
    String? error = validateSubmit(paper);
    if (error != null) throw error;
    await Future.delayed(const Duration(milliseconds: 300));
    // Later: send the paper to the API.
  }

  final List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // "6 Oct 2026"
  String todayText() {
    DateTime now = DateTime.now();
    return '${now.day} ${_months[now.month - 1]} ${now.year}';
  }

  // ---------- Wishlist ----------

  Future<List<String>> getWishes() {
    return _repository.getWishes();
  }

  Future<void> saveWishes(List<String> wishes) {
    return _repository.saveWishes(wishes);
  }

  // Returns an error text, or null when the wish can be saved.
  String? validateWish(String text) {
    if (text.trim().isEmpty) return 'Please write your wish';
    return null;
  }

  // ---------- Trash ----------

  Future<List<PaperDetail>> getAllPapers(String teacherName) {
    return _repository.getAllPapers(teacherName);
  }

  // Puts a deleted question back at the end of the paper.
  void restore(PaperDetail paper, QuestionModel question) {
    paper.trash.remove(question);
    paper.questions.add(question);
    renumber(paper.questions);
  }

  // A copy goes to the paper, the original stays in the trash.
  void copyToPaper(PaperDetail paper, QuestionModel question) {
    paper.questions.add(
      QuestionModel(
        number: paper.questions.length + 1,
        marks: question.marks,
        text: question.text,
        submittedBy: question.submittedBy,
        topic: question.topic,
        clos: List<String>.from(question.clos),
        difficulty: question.difficulty,
        comments: [],
      ),
    );
  }

  void deleteForever(PaperDetail paper, QuestionModel question) {
    paper.trash.remove(question);
  }
}
