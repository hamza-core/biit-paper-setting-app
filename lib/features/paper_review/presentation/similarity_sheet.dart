import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../domain/paper_review_models.dart';
import '../domain/paper_review_service.dart';

// Opens the "Paper Similarity Report" bottom sheet.
void showSimilaritySheet(BuildContext context, String code) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: _SimilaritySheet(code: code),
    ),
  );
}

class _SimilaritySheet extends StatefulWidget {
  final String code;

  const _SimilaritySheet({required this.code});

  @override
  State<_SimilaritySheet> createState() => _SimilaritySheetState();
}

class _SimilaritySheetState extends State<_SimilaritySheet> {
  final PaperReviewService _service = PaperReviewService();
  List<SimilarityMatch>? _matches;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    List<SimilarityMatch> matches = await _service.getSimilarity(widget.code);
    if (!mounted) return;
    setState(() {
      _matches = matches;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<SimilarityMatch>? matches = _matches;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.l,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Paper Similarity Report',
                style: TextStyle(
                  fontSize: AppFontSize.heading,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8E4D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Teachers & Sections',
                  style: TextStyle(
                    fontSize: AppFontSize.label,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '3 teachers',
                  style: TextStyle(
                    fontSize: AppFontSize.caption,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          const Text(
            'Matches with Past Papers',
            style: TextStyle(
              fontSize: AppFontSize.medium,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          if (matches == null)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView(
                children: [
                  for (int i = 0; i < matches.length; i++) ...[
                    _buildMatch(matches[i]),
                    const SizedBox(height: AppSpacing.m),
                  ],
                  const Text(
                    'Each percentage is calculated separately against one past paper, using exact matched questions—not marks.',
                    style: TextStyle(
                      fontSize: AppFontSize.caption,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatch(SimilarityMatch match) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.code,
                  style: const TextStyle(
                    fontSize: AppFontSize.caption,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  match.title,
                  style: const TextStyle(
                    fontSize: AppFontSize.medium,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  match.questionsText,
                  style: const TextStyle(
                    fontSize: AppFontSize.caption,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${match.percent}%',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
