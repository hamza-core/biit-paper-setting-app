import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../domain/director_models.dart';
import '../domain/director_service.dart';
import 'paper_card.dart';

class DirectorPapersScreen extends StatefulWidget {
  final void Function(DirectorPaper paper) onOpenPaper;

  const DirectorPapersScreen({super.key, required this.onOpenPaper});

  @override
  State<DirectorPapersScreen> createState() => _DirectorPapersScreenState();
}

class _DirectorPapersScreenState extends State<DirectorPapersScreen> {
  final DirectorService _service = DirectorService();
  final TextEditingController _searchController = TextEditingController();

  bool _archive = false; // false = Current, true = Archive
  String _currentTab = 'toReview'; // toReview, approved, notSubmitted
  String _archiveTab = 'all'; // all, approved, rejected
  String? _session;
  String? _exam;
  List<DirectorPaper> _papers = [];
  int _totalInArchive = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    List<DirectorPaper> papers = await _service.getPapers(
      archived: _archive,
      statusFilter: _archive ? _archiveTab : _currentTab,
      search: _searchController.text,
      session: _archive ? _session : null,
      exam: _archive ? _exam : null,
    );
    List<DirectorPaper> everything = await _service.getPapers(
      archived: _archive,
      statusFilter: _archive ? _archiveTab : _currentTab,
    );
    if (!mounted) return;
    setState(() {
      _papers = papers;
      _totalInArchive = everything.length;
    });
  }

  Future<void> _paperAction(DirectorPaper paper) async {
    if (paper.status == 'notSubmitted') {
      await _service.sendReminder(paper);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder sent to ${paper.teacher}')),
      );
    } else {
      widget.onOpenPaper(paper);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.s,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: AppSpacing.xxl),
            _buildSwitch(),
            const SizedBox(height: AppSpacing.l),
            _buildSearch(),
            if (_archive) ...[
              const SizedBox(height: AppSpacing.l),
              _buildFilters(),
            ],
            const SizedBox(height: AppSpacing.l),
            _buildListCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/biit_logo.png',
            width: 38,
            height: 38,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _archive ? 'Archived Papers' : 'Current Papers',
              style: const TextStyle(
                fontSize: AppFontSize.heading,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${_papers.length} papers found',
              style: const TextStyle(
                fontSize: AppFontSize.label,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.pillTrack,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          _switchItem('Current', !_archive, () {
            _archive = false;
            _load();
          }),
          const SizedBox(width: 4),
          _switchItem('Archive', _archive, () {
            _archive = true;
            _load();
          }),
        ],
      ),
    );
  }

  Widget _switchItem(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? AppColors.white : AppColors.greyText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _load(),
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search by course name or teacher...',
          hintStyle: TextStyle(fontSize: 14, color: AppColors.greyText),
          prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textDark),
          prefixIconConstraints: BoxConstraints(minWidth: 28),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _filterChip('Session', _session, _service.sessions, (value) {
          _session = value;
          _load();
        }),
        const SizedBox(width: AppSpacing.s),
        _filterChip('Exam Type', _exam, _service.exams, (value) {
          _exam = value;
          _load();
        }),
      ],
    );
  }

  Widget _filterChip(
    String hint,
    String? value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return Container(
      height: 36,
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint),
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
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListCard() {
    List<List<String>> tabs = _archive
        ? [
            ['all', 'All Papers'],
            ['approved', 'Approved'],
            ['rejected', 'Rejected'],
          ]
        : [
            ['toReview', 'To Review'],
            ['approved', 'Approved'],
            ['notSubmitted', 'Not Submitted'],
          ];
    String selected = _archive ? _archiveTab : _currentTab;

    List<String> filterNames = [];
    if (_session != null) filterNames.add(_session!);
    if (_exam != null) filterNames.add(_exam!);
    String filterText = filterNames.isEmpty
        ? 'All sessions'
        : filterNames.join(' • ');

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < tabs.length; i++) ...[
                  _tabItem(tabs[i][1], tabs[i][0] == selected, () {
                    if (_archive) {
                      _archiveTab = tabs[i][0];
                    } else {
                      _currentTab = tabs[i][0];
                    }
                    _load();
                  }),
                  if (i < tabs.length - 1)
                    const SizedBox(width: AppSpacing.xxl),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          if (_archive) ...[
            Text(
              'Showing ${_papers.length} of $_totalInArchive • $filterText',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          if (_papers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.l),
              child: Center(child: Text('No papers found')),
            ),
          for (int i = 0; i < _papers.length; i++) ...[
            DirectorPaperCard(
              paper: _papers[i],
              archived: _archive,
              onAction: () => _paperAction(_papers[i]),
            ),
            if (i < _papers.length - 1) const SizedBox(height: AppSpacing.m),
          ],
        ],
      ),
    );
  }

  Widget _tabItem(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.mutedTab,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Container(
            height: 3,
            width: label.length * 7.5,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
