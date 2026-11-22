import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../../paper_review/domain/paper_review_models.dart';
import '../../paper_review/domain/paper_review_service.dart';
import '../../paper_review/presentation/edit_question_screen.dart';
import '../../paper_review/presentation/similarity_sheet.dart';
import '../domain/faculty_models.dart';
import '../domain/faculty_service.dart';
import 'paper_preview_screen.dart';
import 'trash_screen.dart';
import 'wishlist_screen.dart';

// A copy of the lists, used for undo and redo.
class _Snapshot {
  final List<QuestionModel> questions;
  final List<QuestionModel> extra;
  final List<QuestionModel> trash;

  _Snapshot(this.questions, this.extra, this.trash);
}

// The teacher writes the paper here.
class FacultyWorkspaceScreen extends StatefulWidget {
  final FacultyCourse course;
  final String teacherName;

  const FacultyWorkspaceScreen({
    super.key,
    required this.course,
    required this.teacherName,
  });

  @override
  State<FacultyWorkspaceScreen> createState() => _FacultyWorkspaceScreenState();
}

class _FacultyWorkspaceScreenState extends State<FacultyWorkspaceScreen> {
  final FacultyService _service = FacultyService();
  final PaperReviewService _reviewService = PaperReviewService();
  final TextEditingController _marksController = TextEditingController();

  PaperDetail? _paper;
  bool _extraTab = false;
  int _index = 0;
  final Map<String, String?> _pickedTeachers = {}; // per question slot
  final List<_Snapshot> _undoStack = [];
  final List<_Snapshot> _redoStack = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    PaperDetail paper = await _service.getPaper(
      widget.course,
      widget.teacherName,
    );
    if (!mounted) return;
    setState(() {
      _paper = paper;
      _marksController.text = '${paper.totalMarks}';
    });
  }

  List<QuestionModel> _list() {
    return _extraTab ? _paper!.extraQuestions : _paper!.questions;
  }

  // ---------- undo / redo ----------

  _Snapshot _takeSnapshot() {
    return _Snapshot(
      List<QuestionModel>.from(_paper!.questions),
      List<QuestionModel>.from(_paper!.extraQuestions),
      List<QuestionModel>.from(_paper!.trash),
    );
  }

  void _restore(_Snapshot snapshot) {
    _paper!.questions
      ..clear()
      ..addAll(snapshot.questions);
    _paper!.extraQuestions
      ..clear()
      ..addAll(snapshot.extra);
    _paper!.trash
      ..clear()
      ..addAll(snapshot.trash);
    _service.renumber(_paper!.questions);
    _service.renumber(_paper!.extraQuestions);
    if (_index >= _list().length) _index = _list().length - 1;
    if (_index < 0) _index = 0;
  }

  // Call this before a change to the question lists.
  void _remember() {
    _undoStack.add(_takeSnapshot());
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_takeSnapshot());
    setState(() {
      _restore(_undoStack.removeLast());
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_takeSnapshot());
    setState(() {
      _restore(_redoStack.removeLast());
    });
  }

  // ---------- actions ----------

  void _changeMarks(String text) {
    if (_service.validateTotalMarks(_paper!, text) == null) {
      setState(() {
        _paper!.totalMarks = int.parse(text.trim());
      });
    }
  }

  void _addQuestion() {
    _remember();
    setState(() {
      List<QuestionModel> list = _list();
      list.add(_service.newBlankQuestion(list, widget.teacherName));
      _index = list.length - 1;
    });
  }

  Future<void> _write(QuestionModel question, bool isNew) async {
    EditQuestionResult? result = await Navigator.push<EditQuestionResult>(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuestionScreen(
          question: question,
          isNew: isNew,
          currentUserName: widget.teacherName,
          currentUserRole: 'Faculty',
        ),
      ),
    );
    if (!mounted) return;
    if (result != null && result.deleted) {
      _delete(question);
      return;
    }
    setState(() {});
  }

  void _assign(QuestionModel question) {
    String? teacher =
        _pickedTeachers[question.number.toString() + _extraTab.toString()];
    if (teacher == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a teacher')));
      return;
    }
    _remember();
    setState(() {
      question.assignedTo = teacher;
    });
  }

  void _delete(QuestionModel question) {
    _remember();
    setState(() {
      _service.moveToTrash(_paper!, question);
      if (_index >= _list().length) _index = _list().length - 1;
      if (_index < 0) _index = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Question moved to the trash')),
    );
  }

  void _copy(QuestionModel question) {
    _remember();
    setState(() {
      _paper!.questions.add(_reviewService.copyQuestion(_paper!, question));
      _extraTab = false;
      _index = _paper!.questions.length - 1;
    });
  }

  void _moveToPaper(QuestionModel question) {
    _remember();
    setState(() {
      _service.moveToPaper(_paper!, question);
      if (_index >= _list().length) _index = _list().length - 1;
      if (_index < 0) _index = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Question moved to the paper')),
    );
  }

  Future<void> _openMenu(TapDownDetails details) async {
    String? choice = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        0,
        0,
      ),
      items: const [
        PopupMenuItem(value: 'wishlist', child: Text('Wishlist')),
        PopupMenuItem(value: 'preview', child: Text('Preview')),
        PopupMenuItem(value: 'trash', child: Text('Trash')),
      ],
    );
    if (choice == null || !mounted) return;
    if (choice == 'wishlist') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WishlistScreen()),
      );
    }
    if (choice == 'preview') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaperPreviewScreen(
            paper: _paper!,
            teacherName: widget.teacherName,
          ),
        ),
      );
    }
    if (choice == 'trash') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TrashScreen(papers: [_paper!])),
      );
      // Questions may have been restored.
      if (mounted) {
        setState(() {
          if (_index >= _list().length) _index = _list().length - 1;
          if (_index < 0) _index = 0;
        });
      }
    }
  }

  Future<void> _submit() async {
    try {
      await _service.submitPaper(_paper!);
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _buildSubmittedDialog(dialogContext),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    PaperDetail? paper = _paper;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: paper == null
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xxl,
                        0,
                        AppSpacing.xxl,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        children: [
                          _buildMetaCard(paper),
                          const SizedBox(height: AppSpacing.m),
                          _buildMarksRow(),
                          const SizedBox(height: AppSpacing.m),
                          _buildPaperCard(paper),
                        ],
                      ),
                    ),
            ),
            if (paper != null) _buildActionTray(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.l,
      ),
      child: Row(
        children: [
          BackCircleButton(onTap: () => Navigator.pop(context)),
          const SizedBox(width: AppSpacing.m),
          const Expanded(
            child: Text(
              'Paper Workspace',
              style: TextStyle(
                fontSize: AppFontSize.heading,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          GestureDetector(
            onTapDown: _openMenu,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.more_horiz,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(PaperDetail paper) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  paper.code,
                  style: const TextStyle(
                    fontSize: AppFontSize.caption,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F0FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Due: ${widget.course.dueText}',
                  style: const TextStyle(
                    fontSize: AppFontSize.label,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A5CA8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            paper.courseName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            paper.examText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xCCFFFFFF),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => showSimilaritySheet(context, paper.code),
            child: const Text(
              'Check Similarity',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xCCFFFFFF),
                decoration: TextDecoration.underline,
                decorationColor: Color(0xCCFFFFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarksRow() {
    bool canUndo = _undoStack.isNotEmpty;
    bool canRedo = _redoStack.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Total Marks',
              style: TextStyle(
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 148,
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD7DEDA)),
              ),
              child: TextField(
                controller: _marksController,
                keyboardType: TextInputType.number,
                onChanged: _changeMarks,
                style: const TextStyle(
                  fontSize: AppFontSize.caption,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        _iconButton(Icons.undo, canUndo, _undo),
        const SizedBox(width: AppSpacing.s),
        _iconButton(Icons.redo, canRedo, _redo),
      ],
    );
  }

  Widget _iconButton(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildPaperCard(PaperDetail paper) {
    List<QuestionModel> list = _list();
    String summary = _extraTab
        ? '${list.length} questions · These are excluded from paper.'
        : '${list.length} questions · ${_service.usedMarks(paper)}/${paper.totalMarks} marks';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _tabItem('Full Paper', !_extraTab, () {
                setState(() {
                  _extraTab = false;
                  _index = 0;
                });
              }),
              const SizedBox(width: AppSpacing.xxl),
              _tabItem('Extra Questions', _extraTab, () {
                setState(() {
                  _extraTab = true;
                  _index = 0;
                });
              }),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          if (list.isNotEmpty)
            Text(
              summary,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.greyText,
              ),
            ),
          const SizedBox(height: AppSpacing.s),
          _buildChips(list),
          const SizedBox(height: AppSpacing.s),
          if (list.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: const Color(0xFFD9DED8)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No questions yet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s),
                  Text(
                    'Press ‘+’ icon to add question.',
                    style: TextStyle(
                      fontSize: AppFontSize.caption,
                      color: Color(0xFF5D645F),
                    ),
                  ),
                ],
              ),
            )
          else
            _buildQuestion(list[_index]),
          if (list.length > 1) ...[
            const SizedBox(height: AppSpacing.m),
            _buildPagination(list.length),
          ],
        ],
      ),
    );
  }

  Widget _tabItem(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.mutedTab,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Container(
              height: 3,
              width: label.length * 7.5,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChips(List<QuestionModel> list) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (int i = 0; i < list.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _index = i;
                    });
                  },
                  child: Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: i == _index
                          ? AppColors.successBackground
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD7DEDA)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.drag_indicator,
                          size: 10,
                          color: AppColors.inactiveTab,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Q${list[i].number}',
                          style: const TextStyle(
                            fontSize: AppFontSize.tiny,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _addQuestion,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 16, color: AppColors.white),
          ),
        ),
      ],
    );
  }

  // A question can be blank, given to a teacher, or written.
  Widget _buildQuestion(QuestionModel q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _questionTop(q),
          if (q.isWritten)
            ..._writtenBody(q)
          else if (q.assignedTo != null)
            ..._assignedBody(q)
          else
            ..._blankBody(q),
        ],
      ),
    );
  }

  Widget _questionTop(QuestionModel q) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Q${q.number}',
          style: const TextStyle(
            fontSize: AppFontSize.heading,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        Row(
          children: [
            if (q.isWritten && !_extraTab)
              GestureDetector(
                onTap: () => _copy(q),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    Icons.filter_none,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () => _delete(q),
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFF8B2020),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _blankBody(QuestionModel q) {
    return [
      const SizedBox(height: AppSpacing.s),
      const Text(
        'How would you like to create this question?',
        style: TextStyle(fontSize: 14, color: AppColors.textDark),
      ),
      const SizedBox(height: AppSpacing.m),
      GestureDetector(
        onTap: () => _write(q, true),
        child: Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Create myself',
            style: TextStyle(
              fontSize: AppFontSize.label,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
      const SizedBox(height: 6),
      const Center(
        child: Text(
          'OR',
          style: TextStyle(fontSize: 9, color: AppColors.greyText),
        ),
      ),
      const SizedBox(height: 6),
      _assignRow(q, 'Assign'),
    ];
  }

  List<Widget> _assignedBody(QuestionModel q) {
    return [
      const SizedBox(height: AppSpacing.s),
      Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Assigned To: '),
            TextSpan(
              text: q.assignedTo,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        style: const TextStyle(
          fontSize: AppFontSize.small,
          color: AppColors.textDark,
        ),
      ),
      const SizedBox(height: AppSpacing.m),
      _assignRow(q, 'Change'),
    ];
  }

  Widget _assignRow(QuestionModel q, String buttonText) {
    String key = q.number.toString() + _extraTab.toString();
    List<String> teachers = [];
    for (int i = 0; i < widget.course.teachers.length; i++) {
      teachers.add(widget.course.teachers[i].name);
    }
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD7DEDA)),
            ),
            child: DropdownButton<String>(
              value: teachers.contains(_pickedTeachers[key])
                  ? _pickedTeachers[key]
                  : null,
              hint: const Text('-- Select Teacher --'),
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
              style: const TextStyle(
                fontSize: AppFontSize.label,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              items: [
                for (int i = 0; i < teachers.length; i++)
                  DropdownMenuItem(
                    value: teachers[i],
                    child: Text(teachers[i], overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _pickedTeachers[key] = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        GestureDetector(
          onTap: () => _assign(q),
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: AppFontSize.label,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _writtenBody(QuestionModel q) {
    return [
      const SizedBox(height: AppSpacing.s),
      Text(
        q.text,
        style: const TextStyle(
          fontSize: AppFontSize.small,
          height: 1.45,
          color: AppColors.textDark,
        ),
      ),
      const SizedBox(height: AppSpacing.m),
      if (q.hasDirectorComment) ...[
        const Row(
          children: [
            Icon(Icons.circle, size: 6, color: AppColors.rejectedText),
            SizedBox(width: 6),
            Text(
              'Director commented',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.rejectedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
      ],
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          _pill(
            '${q.marks} marks • ${q.clos.join(', ')}',
            AppColors.successBackground,
            AppColors.primary,
          ),
          _difficultyPill(q.difficulty),
        ],
      ),
      const SizedBox(height: AppSpacing.m),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'By: ${q.submittedBy}',
              style: const TextStyle(
                fontSize: AppFontSize.caption,
                fontWeight: FontWeight.w600,
                color: AppColors.greyText,
              ),
            ),
          ),
          if (_extraTab)
            GestureDetector(
              onTap: () => _moveToPaper(q),
              child: _actionPill('Move to Paper', Icons.arrow_upward),
            )
          else
            GestureDetector(
              onTap: () => _write(q, false),
              child: _actionPill('Edit', Icons.chevron_right),
            ),
        ],
      ),
    ];
  }

  Widget _actionPill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: AppFontSize.caption,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 12, color: AppColors.white),
        ],
      ),
    );
  }

  Widget _pill(String text, Color background, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppFontSize.caption,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _difficultyPill(String difficulty) {
    if (difficulty == 'Hard') {
      return _pill(
        'Hard',
        AppColors.warningBackground,
        const Color(0xFFC62828),
      );
    }
    if (difficulty == 'Easy') {
      return _pill('Easy', AppColors.successBackground, AppColors.successGreen);
    }
    return _pill('Medium', const Color(0xFFFFF3E0), AppColors.warningText);
  }

  Widget _buildPagination(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _arrow('‹', Colors.white, _index > 0, () {
          setState(() {
            _index = _index - 1;
          });
        }),
        const SizedBox(width: 6),
        _arrow('›', AppColors.successBackground, _index < count - 1, () {
          setState(() {
            _index = _index + 1;
          });
        }),
      ],
    );
  }

  Widget _arrow(
    String text,
    Color background,
    bool enabled,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 27,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD7DEDA)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppFontSize.medium,
            color: enabled ? AppColors.primary : AppColors.inactiveTab,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTray() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.l,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: _submit,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Proceed to Decision',
            style: TextStyle(
              fontSize: AppFontSize.medium,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ---------- "Paper Submitted!" dialog ----------

  Widget _buildSubmittedDialog(BuildContext dialogContext) {
    PaperDetail paper = _paper!;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 32,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              const Text(
                'Paper Submitted!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: AppSpacing.xxl),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${paper.code} ${paper.courseName}',
                  style: const TextStyle(
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.course.examText.replaceAll(' • ', ' · ')} · Sections A & B',
                  style: const TextStyle(
                    fontSize: AppFontSize.caption,
                    color: AppColors.greyText,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: AppSpacing.m),
              _infoRow(
                'Status',
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.send_outlined,
                        size: 11,
                        color: AppColors.warningText,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Submitted for Review',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warningText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              _infoRow(
                'Submitted by',
                Text(
                  widget.teacherName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              _infoRow(
                'Submitted on',
                Text(
                  _service.todayText(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const Text(
                'The Director will review and provide feedback.',
                style: TextStyle(
                  fontSize: AppFontSize.caption,
                  fontStyle: FontStyle.italic,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              GestureDetector(
                onTap: () => Navigator.pop(dialogContext),
                child: Container(
                  width: double.infinity,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: const Text(
                    'Back to Paper Workspace',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              GestureDetector(
                onTap: () {
                  Navigator.pop(dialogContext);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Container(
                  width: double.infinity,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Go to Dashboard',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppFontSize.caption,
            color: AppColors.greyText,
          ),
        ),
        value,
      ],
    );
  }
}
