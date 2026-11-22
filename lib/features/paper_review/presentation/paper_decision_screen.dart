import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../domain/paper_review_models.dart';
import '../domain/paper_review_service.dart';
import 'paper_header_card.dart';
import 'similarity_sheet.dart';

// Approve or reject a paper.
class PaperDecisionScreen extends StatefulWidget {
  final PaperDetail paper;
  // Saves the decision. Provided by the screen that opened the review.
  final Future<void> Function(bool approve, String comment) onConfirm;

  const PaperDecisionScreen({
    super.key,
    required this.paper,
    required this.onConfirm,
  });

  @override
  State<PaperDecisionScreen> createState() => _PaperDecisionScreenState();
}

class _PaperDecisionScreenState extends State<PaperDecisionScreen> {
  final PaperReviewService _service = PaperReviewService();
  final TextEditingController _commentController = TextEditingController();

  bool _approve = true;
  bool _saving = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    String? error = _service.validateDecision(
      _approve,
      _commentController.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() {
      _saving = true;
    });
    try {
      await widget.onConfirm(_approve, _commentController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_approve ? 'Paper approved' : 'Paper rejected')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    PaperDetail paper = widget.paper;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.l,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xxl,
                  bottom: AppSpacing.l,
                ),
                child: Row(
                  children: [
                    BackCircleButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(width: AppSpacing.m),
                    const Text(
                      'Paper Decision',
                      style: TextStyle(
                        fontSize: AppFontSize.profileName,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              PaperHeaderCard(
                code: paper.code,
                version: paper.version,
                courseName: paper.courseName,
                examText: paper.examText,
                submittedBy: paper.submittedBy,
                onCheckSimilarity: () =>
                    showSimilaritySheet(context, paper.code),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Select Decision',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              _buildOption(
                approve: true,
                title: 'Approve',
                text: 'Paper meets all requirements and standards.',
                icon: Icons.check_circle_outline,
                titleColor: AppColors.successGreen,
                background: AppColors.successBackground,
              ),
              const SizedBox(height: AppSpacing.m),
              _buildOption(
                approve: false,
                title: 'Reject',
                text: 'Paper does not meet minimum requirements.',
                icon: Icons.cancel_outlined,
                titleColor: AppColors.rejectedText,
                background: AppColors.warningBackground,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF1565C0),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Approved papers are forwarded to the Data Cell for processing.',
                        style: TextStyle(
                          fontSize: AppFontSize.label,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Comments ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    TextSpan(
                      text: '(Required for Request Changes & Reject)',
                      style: TextStyle(
                        fontSize: AppFontSize.caption,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Container(
                constraints: const BoxConstraints(minHeight: 100),
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Add your comments or feedback...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.greyText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _saving
                  ? const SizedBox(
                      height: 48,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : AppButton(
                      text: 'Confirm Decision',
                      compact: true,
                      onPressed: _confirm,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required bool approve,
    required String title,
    required String text,
    required IconData icon,
    required Color titleColor,
    required Color background,
  }) {
    bool selected = _approve == approve;
    return GestureDetector(
      onTap: () {
        setState(() {
          _approve = approve;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? titleColor : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: titleColor),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSize.medium,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: AppFontSize.label,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 18,
              color: selected ? titleColor : AppColors.inactiveTab,
            ),
          ],
        ),
      ),
    );
  }
}
