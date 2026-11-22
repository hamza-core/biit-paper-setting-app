import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../domain/paper_review_models.dart';
import '../domain/paper_review_service.dart';

// What the edit screen sends back to the workspace.
class EditQuestionResult {
  final bool deleted;

  EditQuestionResult({required this.deleted});
}

// Edit (or create) a question, and read / add comments on it.
class EditQuestionScreen extends StatefulWidget {
  final QuestionModel question;
  final bool isNew;
  final String currentUserName;
  final String currentUserRole;

  const EditQuestionScreen({
    super.key,
    required this.question,
    required this.isNew,
    required this.currentUserName,
    required this.currentUserRole,
  });

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final PaperReviewService _service = PaperReviewService();

  late TextEditingController _textController;
  late TextEditingController _marksController;
  final TextEditingController _commentController = TextEditingController();

  int _tab = 0; // 0 = Question, 1 = Comments
  List<String> _topics = [];
  late String _topic;
  late String _clo;
  late String _difficulty;

  @override
  void initState() {
    super.initState();
    QuestionModel q = widget.question;
    _textController = TextEditingController(text: q.text);
    _marksController = TextEditingController(text: '${q.marks}');
    _topic = q.topic;
    _clo = q.clos.join(', ');
    _difficulty = q.difficulty;
    _loadTopics();
  }

  @override
  void dispose() {
    _textController.dispose();
    _marksController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadTopics() async {
    List<String> topics = await _service.getTopics();
    if (!mounted) return;
    setState(() {
      _topics = topics;
      if (!_topics.contains(_topic)) _topics.add(_topic);
    });
  }

  List<String> _cloOptions() {
    List<String> options = List<String>.from(_service.cloChoices);
    if (_clo.isNotEmpty && !options.contains(_clo)) options.add(_clo);
    return options;
  }

  void _save() {
    String? error = _service.validateQuestion(
      _textController.text,
      _marksController.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    QuestionModel q = widget.question;
    q.text = _textController.text.trim();
    q.marks = int.parse(_marksController.text.trim());
    q.topic = _topic;
    q.clos = _clo.isEmpty ? [] : _clo.split(', ');
    q.difficulty = _difficulty;
    Navigator.pop(context, EditQuestionResult(deleted: false));
  }

  Future<void> _delete() async {
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
    if (sure == true && mounted) {
      Navigator.pop(context, EditQuestionResult(deleted: true));
    }
  }

  void _sendComment() {
    if (_commentController.text.trim().isEmpty) return;
    setState(() {
      _service.addComment(
        widget.question,
        _commentController.text,
        widget.currentUserName,
        widget.currentUserRole,
      );
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                10,
                AppSpacing.xxl,
                0,
              ),
              child: _buildTabs(),
            ),
            Expanded(
              child: _tab == 0 ? _buildQuestionTab() : _buildCommentsTab(),
            ),
            _tab == 0 ? _buildQuestionFooter() : _buildCommentFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          BackCircleButton(onTap: () => Navigator.pop(context)),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              widget.isNew ? 'Create Question' : 'Edit Question',
              style: const TextStyle(
                fontSize: AppFontSize.heading,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          if (!widget.isNew)
            GestureDetector(
              onTap: _delete,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Color(0xFF8B2020),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    int commentCount = widget.question.comments.length;
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(child: _tabItem('Question', 0, null)),
          Expanded(child: _tabItem('Comments', 1, commentCount)),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index, int? count) {
    bool selected = _tab == index;
    Color color = selected ? AppColors.primary : AppColors.greyText;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _tab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F2EB),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------- Question tab ----------

  Widget _buildQuestionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.l,
        AppSpacing.xxl,
        AppSpacing.l,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _dropdownField(
                    'Topic',
                    _topic,
                    _topics,
                    (v) => _topic = v,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: _dropdownField(
                    'CLO',
                    _clo,
                    _cloOptions(),
                    (v) => _clo = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildDifficulty()),
                const SizedBox(width: AppSpacing.m),
                Expanded(child: _buildMarks()),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            _label('QUESTION'),
            const SizedBox(height: AppSpacing.s),
            Container(
              height: 134,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: AppFontSize.small,
                  height: 1.45,
                ),
                decoration: const InputDecoration(
                  hintText: 'Write the question...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            _buildToolbar(),
            const SizedBox(height: AppSpacing.m),
            _buildAddPart(),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: AppFontSize.caption,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _dropdownField(
    String label,
    String value,
    List<String> options,
    void Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButton<String>(
            value: options.contains(value) ? value : null,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 16),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            items: [
              for (int i = 0; i < options.length; i++)
                DropdownMenuItem(
                  value: options[i],
                  child: Text(options[i], overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  onChanged(newValue);
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDifficulty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('DIFFICULTY'),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFEAE7DC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFC8C4B8)),
          ),
          child: Row(
            children: [
              for (int i = 0; i < _service.difficulties.length; i++) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _difficulty = _service.difficulties[i];
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _difficulty == _service.difficulties[i]
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _service.difficulties[i] == 'Medium'
                            ? 'Med'
                            : _service.difficulties[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: _difficulty == _service.difficulties[i]
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _difficulty == _service.difficulties[i]
                              ? AppColors.white
                              : const Color(0xFF3A3A3A),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('MARKS'),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: _marksController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    List<IconData> icons = [
      Icons.content_paste,
      Icons.format_bold,
      Icons.format_italic,
      Icons.format_underlined,
      Icons.format_list_bulleted,
      Icons.format_list_numbered,
      Icons.add_photo_alternate_outlined,
      Icons.more_horiz,
    ];
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < icons.length; i++)
            Icon(icons[i], size: 16, color: AppColors.textDark),
        ],
      ),
    );
  }

  Widget _buildAddPart() {
    return GestureDetector(
      onTap: () {
        // A new part is written on a new line of the question.
        _textController.text = '${_textController.text}\n(b) ';
        _textController.selection = TextSelection.collapsed(
          offset: _textController.text.length,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16, color: AppColors.primary),
            SizedBox(width: AppSpacing.s),
            Text(
              'Add Part',
              style: TextStyle(
                fontSize: AppFontSize.small,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.l,
        AppSpacing.xxl,
        AppSpacing.l,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: GestureDetector(
              onTap: _save,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: AppFontSize.small,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Comments tab ----------

  Widget _buildCommentsTab() {
    List<CommentModel> comments = widget.question.comments;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.l,
        AppSpacing.xxl,
        AppSpacing.l,
      ),
      child: Column(
        children: [
          for (int i = 0; i < comments.length; i++) ...[
            _buildComment(comments[i]),
            const SizedBox(height: AppSpacing.l),
          ],
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.greyText),
                SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    'Comments are visible to the submitting teacher.',
                    style: TextStyle(
                      fontSize: AppFontSize.caption,
                      fontStyle: FontStyle.italic,
                      color: AppColors.greyText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(CommentModel comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            _service.initials(comment.authorName),
            style: const TextStyle(
              fontSize: AppFontSize.caption,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Text(
                    comment.authorName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '${comment.authorRole} • ${comment.timeText}',
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.text,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.1,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.l,
        AppSpacing.xxl,
        AppSpacing.l,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 5,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _commentController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(color: AppColors.textDark),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          GestureDetector(
            onTap: _sendComment,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: const Text(
                'Send',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
