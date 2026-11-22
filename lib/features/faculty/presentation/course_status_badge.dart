import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';

// Small colored badge for a course status.
class CourseStatusBadge extends StatelessWidget {
  final String status; // changesRequired, paperToSet or questionsToAdd

  const CourseStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color background = const Color(0xFFFFF3E0);
    Color color = AppColors.warningText;
    IconData icon = Icons.edit_outlined;
    String text = 'Changes Required';

    if (status == 'paperToSet') {
      background = AppColors.successBackground;
      color = AppColors.successGreen;
      icon = Icons.description_outlined;
      text = 'Paper to set';
    } else if (status == 'questionsToAdd') {
      background = const Color(0xFFE3F2FD);
      color = const Color(0xFF1565C0);
      icon = Icons.help_outline;
      text = 'Questions to add';
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
          const SizedBox(width: 5),
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
}
