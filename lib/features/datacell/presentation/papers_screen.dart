import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../domain/datacell_service.dart';
import '../domain/paper_model.dart';

class DatacellPapersScreen extends StatefulWidget {
  final VoidCallback onBack;

  const DatacellPapersScreen({super.key, required this.onBack});

  @override
  State<DatacellPapersScreen> createState() => _DatacellPapersScreenState();
}

class _DatacellPapersScreenState extends State<DatacellPapersScreen> {
  final DatacellService _service = DatacellService();
  final TextEditingController _searchController = TextEditingController();

  String _tab = 'all';
  String _session = 'Fall 2026';
  String _exam = 'Final';
  List<PaperModel> _papers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPapers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPapers() async {
    List<PaperModel> papers = await _service.getPapers(
      tab: _tab,
      search: _searchController.text,
      session: _session,
      exam: _exam,
    );
    if (!mounted) return;
    setState(() {
      _papers = papers;
      _loading = false;
    });
  }

  Future<void> _submit(PaperModel paper) async {
    await _service.submitPaper(paper);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${paper.courseName} submitted')));
    _loadPapers();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearch(),
            _buildFilters(),
            _buildListCard(),
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
          BackCircleButton(onTap: widget.onBack),
          const SizedBox(width: AppSpacing.m),
          const Text(
            'Papers',
            style: TextStyle(
              fontSize: AppFontSize.heading,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.s,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _loadPapers(),
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Search by course name or code...',
            hintStyle: TextStyle(fontSize: 14, color: AppColors.greyText),
            prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textDark),
            prefixIconConstraints: BoxConstraints(minWidth: 28),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          _filterChip(_session, _service.sessions, (value) {
            _session = value;
            _loadPapers();
          }),
          const SizedBox(width: AppSpacing.s),
          _filterChip(_exam, _service.exams, (value) {
            _exam = value;
            _loadPapers();
          }),
        ],
      ),
    );
  }

  Widget _filterChip(
    String value,
    List<String> options,
    void Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 8),
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        isDense: true,
        icon: const Icon(Icons.arrow_drop_down, size: 18),
        style: const TextStyle(
          fontSize: AppFontSize.label,
          fontWeight: FontWeight.w500,
          color: AppColors.greyText,
        ),
        items: [
          for (int i = 0; i < options.length; i++)
            DropdownMenuItem(value: options[i], child: Text(options[i])),
        ],
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }

  Widget _buildListCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.s,
      ),
      child: Container(
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
            _buildTabs(),
            const SizedBox(height: AppSpacing.m),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_papers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.l),
                child: Center(child: Text('No papers found')),
              )
            else
              for (int i = 0; i < _papers.length; i++) ...[
                _buildPaperCard(_papers[i]),
                if (i < _papers.length - 1)
                  const SizedBox(height: AppSpacing.m),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tabItem('All', 'all'),
        const SizedBox(width: 19),
        _tabItem('Submitted', 'submitted'),
        const SizedBox(width: 19),
        _tabItem('Not Submitted', 'notSubmitted'),
      ],
    );
  }

  Widget _tabItem(String label, String value) {
    bool selected = _tab == value;
    return GestureDetector(
      onTap: () {
        _tab = value;
        _loadPapers();
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primary : AppColors.greyText,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Container(
            height: 3,
            width: label.length * 7.0,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperCard(PaperModel paper) {
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
                '${paper.code} • ${paper.version}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  decoration: TextDecoration.underline,
                ),
              ),
              _buildStatusBadge(paper.isSubmitted),
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
          _infoRow(
            Icons.description_outlined,
            'Exam: ',
            '${paper.session} • ${paper.exam}',
            12,
          ),
          const SizedBox(height: 4),
          _infoRow(
            Icons.calendar_today_outlined,
            'Submitted by: ',
            paper.submittedBy,
            13,
          ),
          if (!paper.isSubmitted) ...[
            const SizedBox(height: 5),
            const Divider(height: 1, color: Color(0xFFD0EBD2)),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _submit(paper),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: AppFontSize.caption,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, double size) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.greyText),
        const SizedBox(width: 6),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
            style: TextStyle(fontSize: size, color: AppColors.greyText),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool submitted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: submitted
            ? AppColors.successBackground
            : AppColors.warningBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            submitted ? Icons.check_circle_outline : Icons.schedule,
            size: 14,
            color: submitted ? AppColors.successGreen : AppColors.warningText,
          ),
          const SizedBox(width: 4),
          Text(
            submitted ? 'Submitted' : 'Not Submitted',
            style: TextStyle(
              fontSize: AppFontSize.caption,
              fontWeight: FontWeight.w700,
              color: submitted ? AppColors.successGreen : AppColors.warningText,
            ),
          ),
        ],
      ),
    );
  }
}
