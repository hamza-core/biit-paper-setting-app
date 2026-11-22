import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../domain/paper_review_models.dart';
import '../domain/paper_review_service.dart';
import 'covered_topics_sheet.dart';
import 'edit_question_screen.dart';
import 'paper_decision_screen.dart';
import 'paper_header_card.dart';
import 'similarity_sheet.dart';

// The paper with all its questions. The reviewer can edit, comment,
// check topics / CLOs and then go to the decision.
class PaperWorkspaceScreen extends StatefulWidget {
  final String code;
  final String courseName;
  final String submittedBy;
  final String currentUserName;
  final String currentUserRole;
  final bool canDecide; // false = view only (approved / rejected papers)
  final Future<void> Function(bool approve, String comment)? onConfirmDecision;

  const PaperWorkspaceScreen({
    super.key,
    required this.code,
    required this.courseName,
    required this.submittedBy,
    required this.currentUserName,
    required this.currentUserRole,
    required this.canDecide,
    this.onConfirmDecision,
  });

  @override
  State<PaperWorkspaceScreen> createState() => _PaperWorkspaceScreenState();
}

class _PaperWorkspaceScreenState extends State<PaperWorkspaceScreen> {
  final PaperReviewService _service = PaperReviewService();

  PaperDetail? _paper;
  bool _extraTab = false; // false = Full Paper, true = Extra Questions
  int _index = 0; // which question is shown

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    PaperDetail paper = await _service.getPaper(
      code: widget.code,
      courseName: widget.courseName,
      submittedBy: widget.submittedBy,
    );
    if (!mounted) return;
    setState(() {
      _paper = paper;
    });
  }

  List<QuestionModel> _list() {
    return _extraTab ? _paper!.extraQuestions : _paper!.questions;
  }

  Future<void> _openEdit(QuestionModel question, bool isNew) async {
    EditQuestionResult? result = await Navigator.push<EditQuestionResult>(
      context,
      MaterialPageRoute(
        builder: (context) => EditQuestionScreen(
          question: question,
          isNew: isNew,
          currentUserName: widget.currentUserName,
          currentUserRole: widget.currentUserRole,
        ),
      ),
    );
    if (result == null) {
      // The screen was closed without saving. A new question is thrown away.
      setState(() {});
      return;
    }
    if (result.deleted) {
      await _service.deleteQuestion(_paper!, question, _extraTab);
      if (_index >= _list().length) _index = _list().length - 1;
      if (_index < 0) _index = 0;
    } else {
      await _service.saveQuestion(_paper!, question, _extraTab);
      _index = _list().indexOf(question);
    }
    if (!mounted) return;
    setState(() {});
  }

  void _addQuestion() {
    List<QuestionModel> list = _list();
    QuestionModel question = QuestionModel(
      number: list.length + 1,
      marks: 5,
      text: '',
      submittedBy: widget.currentUserName,
      topic: 'Compiler Phases',
      clos: ['CLO-1'],
      difficulty: 'Medium',
      comments: [],
    );
    _openEdit(question, true);
  }

  Future<void> _copyQuestion(QuestionModel question) async {
    QuestionModel copy = _service.copyQuestion(_paper!, question);
    await _service.saveQuestion(_paper!, copy, false);
    if (!mounted) return;
    setState(() {
      _extraTab = false;
      _index = _paper!.questions.length - 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Q${question.number} copied to the paper')),
    );
  }

  Future<void> _deleteQuestion(QuestionModel question) async {
    bool? sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete question?'),
        content: const Text('This question will be removed from the paper.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await _service.deleteQuestion(_paper!, question, _extraTab);
    if (!mounted) return;
    setState(() {
      if (_index >= _list().length) _index = _list().length - 1;
      if (_index < 0) _index = 0;
    });
  }

  void _openDecision() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaperDecisionScreen(
          paper: _paper!,
          onConfirm: widget.onConfirmDecision!,
        ),
      ),
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
        PopupMenuItem(value: 'similarity', child: Text('Check Similarity')),
        PopupMenuItem(
          value: 'topics',
          child: Text('Covered Topics & CLO Grid'),
        ),
      ],
    );
    if (!mounted) return;
    if (choice == 'similarity') showSimilaritySheet(context, widget.code);
    if (choice == 'topics' && _paper != null) {
      showCoveredTopicsSheet(context, _paper!);
    }
  }

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
                          PaperHeaderCard(
                            code: paper.code,
                            version: paper.version,
                            courseName: paper.courseName,
                            examText: paper.examText,
                            submittedBy: paper.submittedBy,
                            onCheckSimilarity: () =>
                                showSimilaritySheet(context, paper.code),
                          ),
                          const SizedBox(height: AppSpacing.l),
                          _buildTopicsButton(paper),
                          const SizedBox(height: AppSpacing.l),
                          _buildPaperCard(paper),
                        ],
                      ),
                    ),
            ),
            if (widget.canDecide && paper != null) _buildActionTray(),
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
            child: const CircleIconButton(icon: Icons.more_horiz),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsButton(PaperDetail paper) {
    return GestureDetector(
      onTap: () => showCoveredTopicsSheet(context, paper),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Check Covered Topics  & CLO Grid',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward, size: 18, color: AppColors.white),
          ],
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
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: Text('No questions yet')),
            )
          else
            _buildQuestionCard(list[_index]),
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
    return Center(
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
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
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel q) {
    int commentCount = q.comments.length;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _pill(
                'Q${q.number} • ${q.marks} Marks',
                AppColors.successBackground,
                AppColors.primary,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _copyQuestion(q),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.filter_none,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _deleteQuestion(q),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
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
          ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Submitted By: ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: q.submittedBy),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _pill(
                q.clos.join(', '),
                const Color(0xFFE8E4D9),
                AppColors.greyText,
              ),
              _difficultyPill(q.difficulty),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: AppColors.greyText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    commentCount == 1 ? '1 comment' : '$commentCount comments',
                    style: const TextStyle(
                      fontSize: AppFontSize.label,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _openEdit(q, false),
                child: const SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Text(
                        'Edit / Comment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
        onTap: _openDecision,
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
}
