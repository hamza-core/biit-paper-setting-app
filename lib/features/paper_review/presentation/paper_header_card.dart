import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';

// Green card with the course name, used on the workspace and decision screens.
class PaperHeaderCard extends StatelessWidget {
  final String code;
  final String version;
  final String courseName;
  final String examText;
  final String submittedBy;
  final VoidCallback onCheckSimilarity;

  const PaperHeaderCard({
    super.key,
    required this.code,
    required this.version,
    required this.courseName,
    required this.examText,
    required this.submittedBy,
    required this.onCheckSimilarity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
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
                  code,
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
                  version,
                  style: const TextStyle(
                    fontSize: AppFontSize.label,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A5CA8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            courseName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            examText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xCCFFFFFF),
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onCheckSimilarity,
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
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0x33FFFFFF)),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(
                width: 140,
                child: Text(
                  'Submitted by:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  submittedBy,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
