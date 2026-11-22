import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../domain/paper_review_models.dart';
import '../domain/paper_review_service.dart';

// Opens the "Covered Topics & CLO Grid" bottom sheet.
void showCoveredTopicsSheet(BuildContext context, PaperDetail paper) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: _CoveredTopicsSheet(paper: paper),
    ),
  );
}

class _CoveredTopicsSheet extends StatefulWidget {
  final PaperDetail paper;

  const _CoveredTopicsSheet({required this.paper});

  @override
  State<_CoveredTopicsSheet> createState() => _CoveredTopicsSheetState();
}

class _CoveredTopicsSheetState extends State<_CoveredTopicsSheet> {
  final PaperReviewService _service = PaperReviewService();
  final List<String> _tabs = ['Common Topics', 'Detail', 'CLO Grid'];

  int _tab = 0;
  CoveredTopics? _topics;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    CoveredTopics topics = await _service.getCoveredTopics(widget.paper.code);
    if (!mounted) return;
    setState(() {
      _topics = topics;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.l,
        AppSpacing.xxl,
        0,
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
                'Covered Topics & CLO Grid',
                style: TextStyle(
                  fontSize: AppFontSize.small,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F2EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          _buildTabs(),
          const SizedBox(height: AppSpacing.l),
          Expanded(
            child: _topics == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(child: _buildContent(_topics!)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _tabs.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    _tab = i;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _tab == i
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _tab == i ? AppColors.primary : AppColors.greyText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(CoveredTopics topics) {
    if (_tab == 0) return _buildCommon(topics);
    if (_tab == 1) return _buildDetail(topics);
    return _buildCloGrid();
  }

  // Topics that every teacher marked.
  Widget _buildCommon(CoveredTopics topics) {
    List<TopicRow> common = [];
    for (int i = 0; i < topics.rows.length; i++) {
      if (topics.rows[i].coveredByAll) common.add(topics.rows[i]);
    }
    return _card(
      Column(
        children: [
          for (int i = 0; i < common.length; i++) ...[
            Row(
              children: [
                const Icon(Icons.circle, size: 8, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  common[i].topic,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            if (i < common.length - 1) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
            ],
          ],
          if (common.isEmpty) const Text('No common topics'),
        ],
      ),
    );
  }

  Widget _buildDetail(CoveredTopics topics) {
    const header = TextStyle(
      fontSize: AppFontSize.caption,
      color: AppColors.greyText,
    );
    return _card(
      Column(
        children: [
          Row(
            children: [
              const Expanded(child: Text('Topic', style: header)),
              for (int i = 0; i < topics.teacherNames.length; i++)
                SizedBox(
                  width: 90,
                  child: Text(
                    topics.teacherNames[i],
                    textAlign: TextAlign.center,
                    style: header,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          for (int r = 0; r < topics.rows.length; r++) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      topics.rows[r].topic,
                      style: TextStyle(
                        fontSize: AppFontSize.label,
                        color: topics.rows[r].coveredByAll
                            ? AppColors.textDark
                            : AppColors.inactiveTab,
                      ),
                    ),
                  ),
                  for (
                    int t = 0;
                    t < topics.rows[r].coveredByTeacher.length;
                    t++
                  )
                    SizedBox(
                      width: 90,
                      child: Center(
                        child: _tick(topics.rows[r].coveredByTeacher[t]),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tick(bool covered) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: covered ? AppColors.successBackground : const Color(0xFFEFEDE6),
        shape: BoxShape.circle,
      ),
      child: Icon(
        covered ? Icons.check : Icons.close,
        size: 12,
        color: covered ? AppColors.primary : AppColors.greyText,
      ),
    );
  }

  Widget _buildCloGrid() {
    List<CloGridRow> rows = _service.cloGrid(widget.paper);
    const header = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      color: AppColors.greyText,
    );
    const cell = TextStyle(fontSize: 9, color: AppColors.greyText);

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Final Exam • ${_service.usedMarks(widget.paper)} Marks',
            style: const TextStyle(
              fontSize: AppFontSize.small,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          const Text(
            'CLO Summary',
            style: TextStyle(
              fontSize: AppFontSize.label,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFFF4F2EB),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Question', style: header)),
                Expanded(child: Text('CLO-1', style: header)),
                Expanded(child: Text('CLO-2', style: header)),
                Expanded(child: Text('CLO-3', style: header)),
                Expanded(child: Text('CLO-4', style: header)),
                Expanded(flex: 2, child: Text('Status', style: header)),
              ],
            ),
          ),
          for (int i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(rows[i].question, style: cell)),
                  for (int c = 0; c < 4; c++)
                    Expanded(
                      child: Text(rows[i].clos[c] ? 'OK' : '-', style: cell),
                    ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      rows[i].valid ? 'Valid' : 'Not Valid',
                      style: cell,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: const Color(0xFFE5E1D5)),
      ),
      child: child,
    );
  }
}
