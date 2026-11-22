import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../domain/faculty_models.dart';
import '../domain/faculty_service.dart';
import 'course_details_screen.dart';
import 'faculty_home_screen.dart';

// Papers tab: Current (my courses) and Archive (past papers).
class FacultyPapersScreen extends StatefulWidget {
  final String teacherName; // the logged in teacher

  const FacultyPapersScreen({super.key, required this.teacherName});

  @override
  State<FacultyPapersScreen> createState() => _FacultyPapersScreenState();
}

class _FacultyPapersScreenState extends State<FacultyPapersScreen> {
  final FacultyService _service = FacultyService();
  final TextEditingController _searchController = TextEditingController();

  bool _archive = false;
  String _archiveTab = 'all'; // all, approved, rejected
  String? _session;
  String? _exam;
  List<FacultyCourse> _courses = [];
  List<ArchivedPaper> _papers = [];
  int _archiveTotal = 0;

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
    List<FacultyCourse> courses = await _service.getCourses(
      search: _searchController.text,
    );
    List<ArchivedPaper> papers = await _service.getArchive(
      tab: _archiveTab,
      search: _searchController.text,
      session: _session,
      exam: _exam,
    );
    List<ArchivedPaper> everything = await _service.getArchive(
      tab: _archiveTab,
    );
    if (!mounted) return;
    setState(() {
      _courses = courses;
      _papers = papers;
      _archiveTotal = everything.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.m,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Text(
                  _archive ? 'Past Papers' : 'Current Papers',
                  style: const TextStyle(
                    fontSize: AppFontSize.heading,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            _buildSwitch(),
            const SizedBox(height: AppSpacing.l),
            _buildSearch(),
            if (_archive) ...[
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  _filterChip(
                    'Session',
                    _session,
                    _service.sessions,
                    (v) => _session = v,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  _filterChip(
                    'Exam Type',
                    _exam,
                    _service.exams,
                    (v) => _exam = v,
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.l),
            _archive ? _buildArchiveCard() : _buildCurrentCard(),
          ],
        ),
      ),
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
        onChanged: (newValue) {
          onChanged(newValue);
          _load();
        },
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }

  Widget _buildCurrentCard() {
    return _card(
      Column(
        children: [
          if (_courses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.l),
              child: Center(child: Text('No courses found')),
            ),
          for (int i = 0; i < _courses.length; i++) ...[
            FacultyCourseCard(
              course: _courses[i],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseDetailsScreen(
                      course: _courses[i],
                      teacherName: widget.teacherName,
                    ),
                  ),
                );
              },
            ),
            if (i < _courses.length - 1) const SizedBox(height: AppSpacing.m),
          ],
        ],
      ),
    );
  }

  Widget _buildArchiveCard() {
    List<List<String>> tabs = [
      ['all', 'All'],
      ['approved', 'Approved'],
      ['rejected', 'Rejected'],
    ];
    List<String> filterNames = [];
    if (_session != null) filterNames.add(_session!);
    if (_exam != null) filterNames.add(_exam!);
    String filterText = filterNames.isEmpty
        ? 'All sessions'
        : filterNames.join(' • ');

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (int i = 0; i < tabs.length; i++) ...[
                GestureDetector(
                  onTap: () {
                    _archiveTab = tabs[i][0];
                    _load();
                  },
                  child: Column(
                    children: [
                      Text(
                        tabs[i][1],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _archiveTab == tabs[i][0]
                              ? AppColors.primary
                              : AppColors.greyText,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      Container(
                        height: 3,
                        width: tabs[i][1].length * 7.5,
                        decoration: BoxDecoration(
                          color: _archiveTab == tabs[i][0]
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < tabs.length - 1) const SizedBox(width: AppSpacing.xxl),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Showing ${_papers.length} of $_archiveTotal • $filterText',
            style: const TextStyle(fontSize: 11, color: AppColors.greyText),
          ),
          const SizedBox(height: AppSpacing.m),
          if (_papers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.l),
              child: Center(child: Text('No papers found')),
            ),
          for (int i = 0; i < _papers.length; i++) ...[
            _buildArchivedCard(_papers[i]),
            if (i < _papers.length - 1) const SizedBox(height: AppSpacing.m),
          ],
        ],
      ),
    );
  }

  Widget _buildArchivedCard(ArchivedPaper paper) {
    bool approved = paper.result == 'approved';
    Color color = approved ? AppColors.successGreen : AppColors.rejectedText;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
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
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  decoration: TextDecoration.underline,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: approved
                      ? AppColors.successBackground
                      : AppColors.warningBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      approved
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      approved ? 'Approved' : 'Rejected',
                      style: TextStyle(
                        fontSize: AppFontSize.caption,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  paper.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
