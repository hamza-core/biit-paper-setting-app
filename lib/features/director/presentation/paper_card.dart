import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../domain/director_models.dart';

// Card for one paper. The text, badge and action depend on the status.
// `archived` is true on the Archive tab (simpler card, "View Paper").
class DirectorPaperCard extends StatelessWidget {
  final DirectorPaper paper;
  final bool archived;
  final VoidCallback onAction;

  const DirectorPaperCard({
    super.key,
    required this.paper,
    required this.onAction,
    this.archived = false,
  });

  @override
  Widget build(BuildContext context) {
    bool rejected = paper.status == 'rejected';
    Color dividerColor = rejected
        ? const Color(0xFFFFCDD2)
        : const Color(0xFFD0EBD2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
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
              Text(
                paper.code,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  decoration: archived ? TextDecoration.underline : null,
                ),
              ),
              _buildBadge(),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            paper.courseName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 5),
          _buildInfo(),
          const SizedBox(height: 5),
          Divider(height: 1, color: dividerColor),
          const SizedBox(height: 5),
          Align(alignment: Alignment.centerRight, child: _buildAction()),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    Color background = AppColors.successBackground;
    Color color = AppColors.successGreen;
    IconData icon = Icons.check_circle_outline;
    String text = 'Approved';

    if (paper.status == 'toReview') {
      background = AppColors.reviewBackground;
      color = AppColors.reviewText;
      icon = Icons.schedule;
      text = 'Waiting for your review';
    } else if (paper.status == 'notSubmitted') {
      background = const Color(0xFFECE9E0);
      color = AppColors.greyText;
      icon = Icons.event_busy_outlined;
      text = 'Not submitted';
    } else if (paper.status == 'rejected') {
      background = AppColors.warningBackground;
      color = AppColors.rejectedText;
      icon = Icons.cancel_outlined;
      text = 'Rejected';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: AppFontSize.caption,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    const normal = TextStyle(fontSize: 13, color: Color(0xFF5F5E5A));
    const bold = TextStyle(fontWeight: FontWeight.w700);

    if (archived) {
      return Row(
        children: [
          const Icon(Icons.person_outline, size: 14, color: AppColors.greyText),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Submitted By: ', style: bold),
                  TextSpan(text: paper.teacher),
                ],
              ),
              style: const TextStyle(fontSize: 12, color: AppColors.greyText),
            ),
          ),
        ],
      );
    }

    if (paper.status == 'toReview') {
      return Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Submitted by ', style: bold),
            TextSpan(text: '${paper.teacher} · ${paper.dateText}'),
          ],
        ),
        style: normal,
      );
    }
    if (paper.status == 'approved') {
      return Text(
        '${paper.teacher} · approved ${paper.dateText}',
        style: normal,
      );
    }
    return Text('${paper.teacher} · due ${paper.dateText}', style: normal);
  }

  Widget _buildAction() {
    String text = 'View paper';
    Color color = AppColors.primary;
    IconData? leading;

    if (paper.status == 'toReview') text = 'Review Paper';
    if (paper.status == 'notSubmitted') {
      text = 'Send reminder';
      leading = Icons.notifications_none;
    }
    if (paper.status == 'rejected') {
      text = 'View Paper';
      color = AppColors.rejectedText;
    }
    if (archived && paper.status == 'approved') text = 'View Paper';

    return GestureDetector(
      onTap: onAction,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            Icon(leading, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 14, color: color),
        ],
      ),
    );
  }
}
