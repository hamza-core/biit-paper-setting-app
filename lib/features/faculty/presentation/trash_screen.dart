import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/change_history.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../../paper_review/domain/paper_review_models.dart';
import '../domain/faculty_service.dart';

// What the lists of a paper looked like (for undo and redo).
class _PaperLists {
  final List<QuestionModel> questions;
  final List<QuestionModel> trash;

  _PaperLists(this.questions, this.trash);
}

// Deleted questions. They can be restored to their paper.
class TrashScreen extends StatefulWidget {
  final List<PaperDetail> papers;

  const TrashScreen({super.key, required this.papers});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final FacultyService _service = FacultyService();
  final ChangeHistory<List<_PaperLists>> _history =
      ChangeHistory<List<_PaperLists>>();

  // One row of the screen: a question and the paper it came from.
  List<MapEntry<PaperDetail, QuestionModel>> _items() {
    List<MapEntry<PaperDetail, QuestionModel>> items = [];
    for (int p = 0; p < widget.papers.length; p++) {
      for (int q = widget.papers[p].trash.length - 1; q >= 0; q--) {
        // newest first
        items.add(MapEntry(widget.papers[p], widget.papers[p].trash[q]));
      }
    }
    return items;
  }

  List<_PaperLists> _snapshot() {
    return [
      for (int i = 0; i < widget.papers.length; i++)
        _PaperLists(
          List<QuestionModel>.from(widget.papers[i].questions),
          List<QuestionModel>.from(widget.papers[i].trash),
        ),
    ];
  }

  void _restoreSnapshot(List<_PaperLists> snapshot) {
    for (int i = 0; i < widget.papers.length; i++) {
      widget.papers[i].questions
        ..clear()
        ..addAll(snapshot[i].questions);
      widget.papers[i].trash
        ..clear()
        ..addAll(snapshot[i].trash);
      _service.renumber(widget.papers[i].questions);
    }
  }

  void _change(void Function() change) {
    _history.remember(_snapshot());
    setState(change);
  }

  void _undo() {
    List<_PaperLists>? before = _history.undo(_snapshot());
    if (before == null) return;
    setState(() {
      _restoreSnapshot(before);
    });
  }

  void _redo() {
    List<_PaperLists>? after = _history.redo(_snapshot());
    if (after == null) return;
    setState(() {
      _restoreSnapshot(after);
    });
  }

  Future<void> _deleteForever(PaperDetail paper, QuestionModel question) async {
    bool? sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete forever?'),
        content: const Text('This question cannot be restored after this.'),
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
    if (sure == true) {
      _change(() => _service.deleteForever(paper, question));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<PaperDetail, QuestionModel>> items = _items();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.l,
              ),
              child: Row(
                children: [
                  BackCircleButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: AppSpacing.m),
                  const Text(
                    'Trash',
                    style: TextStyle(
                      fontSize: AppFontSize.heading,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  0,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                ),
                child: _buildCard(items),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<MapEntry<PaperDetail, QuestionModel>> items) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'My Trash '),
                    TextSpan(
                      text: '(${items.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5D645F),
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Row(
                children: [
                  _historyButton(Icons.undo, _history.canUndo, _undo),
                  const SizedBox(width: 6),
                  _historyButton(Icons.redo, _history.canRedo, _redo),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.l),
              child: Center(child: Text('The trash is empty')),
            ),
          for (int i = 0; i < items.length; i++) ...[
            _buildItem(i + 1, items[i].key, items[i].value),
            if (i < items.length - 1) const SizedBox(height: AppSpacing.s),
          ],
        ],
      ),
    );
  }

  Widget _historyButton(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildItem(int number, PaperDetail paper, QuestionModel question) {
    String where = widget.papers.length > 1 ? '${paper.code} · ' : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7DEDA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: AppFontSize.caption,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        _change(() => _service.copyToPaper(paper, question)),
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
                    onTap: () => _deleteForever(paper, question),
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
          const SizedBox(height: 5),
          Text(
            question.text.isEmpty ? 'Empty question slot' : question.text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$where${question.topic} · ${question.marks} marks',
            style: const TextStyle(
              fontSize: AppFontSize.caption,
              color: Color(0xFF5D645F),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _change(() => _service.restore(paper, question)),
              child: const SizedBox(
                height: 36,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Restore ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      Icons.restore_from_trash_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
