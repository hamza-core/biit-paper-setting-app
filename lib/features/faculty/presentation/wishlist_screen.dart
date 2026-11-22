import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/change_history.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../domain/faculty_service.dart';

// The teacher's wishes for the next papers.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final FacultyService _service = FacultyService();
  final ChangeHistory<List<String>> _history = ChangeHistory<List<String>>();

  List<String> _wishes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    List<String> wishes = await _service.getWishes();
    if (!mounted) return;
    setState(() {
      _wishes = wishes;
      _loading = false;
    });
  }

  // Runs a change, remembering the list before it.
  Future<void> _change(void Function(List<String> wishes) change) async {
    _history.remember(List<String>.from(_wishes));
    setState(() {
      change(_wishes);
    });
    await _service.saveWishes(_wishes);
  }

  Future<void> _undo() async {
    List<String>? before = _history.undo(List<String>.from(_wishes));
    if (before == null) return;
    setState(() {
      _wishes = before;
    });
    await _service.saveWishes(_wishes);
  }

  Future<void> _redo() async {
    List<String>? after = _history.redo(List<String>.from(_wishes));
    if (after == null) return;
    setState(() {
      _wishes = after;
    });
    await _service.saveWishes(_wishes);
  }

  // The dialog "Add a wish". Returns the text, or null when cancelled.
  Future<String?> _askWish({
    String start = '',
    String title = 'Add a wish',
    String button = 'Add to wishlist',
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) =>
          _WishDialog(start: start, title: title, button: button),
    );
  }

  Future<void> _add() async {
    String? text = await _askWish();
    if (text != null) {
      // newest wish on top
      await _change((wishes) => wishes.insert(0, text));
    }
  }

  Future<void> _edit(int index) async {
    String? text = await _askWish(
      start: _wishes[index],
      title: 'Edit wish',
      button: 'Save wish',
    );
    if (text != null) {
      await _change((wishes) => wishes[index] = text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                        'Wishlist',
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
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xxl,
                            0,
                            AppSpacing.xxl,
                            110,
                          ),
                          child: _buildCard(),
                        ),
                ),
              ],
            ),
            Positioned(
              right: AppSpacing.xxl,
              bottom: AppSpacing.xxl,
              child: Material(
                color: AppColors.primary,
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _add,
                  child: const SizedBox(
                    width: 76,
                    height: 63,
                    child: Icon(Icons.add, size: 24, color: AppColors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
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
                    const TextSpan(text: 'My Wishlist '),
                    TextSpan(
                      text: '(${_wishes.length})',
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
          if (_wishes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.l),
              child: Center(child: Text('No wishes yet. Press + to add one.')),
            ),
          for (int i = 0; i < _wishes.length; i++) ...[
            _buildWish(i),
            if (i < _wishes.length - 1) const SizedBox(height: AppSpacing.s),
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

  Widget _buildWish(int index) {
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
                  '${index + 1}',
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
                    onTap: () => _change(
                      (wishes) => wishes.insert(index + 1, wishes[index]),
                    ),
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
                    onTap: () => _change((wishes) => wishes.removeAt(index)),
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
            _wishes[index],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: AppColors.textDark,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _edit(index),
              child: const SizedBox(
                height: 36,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
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

// The dialog with the text box. It owns its text controller.
class _WishDialog extends StatefulWidget {
  final String start;
  final String title;
  final String button;

  const _WishDialog({
    required this.start,
    required this.title,
    required this.button,
  });

  @override
  State<_WishDialog> createState() => _WishDialogState();
}

class _WishDialogState extends State<_WishDialog> {
  final FacultyService _service = FacultyService();
  late TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.start);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    String? problem = _service.validateWish(_controller.text);
    if (problem != null) {
      setState(() {
        _error = problem;
      });
      return;
    }
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Your wish',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Container(
              height: 110,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Write your wish...',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: AppFontSize.caption,
                    color: AppColors.rejectedText,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _save,
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.button,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
