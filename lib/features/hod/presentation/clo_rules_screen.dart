import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../domain/hod_models.dart';
import '../domain/hod_service.dart';

// CLO Rule tab: the HOD chooses the CLOs of every course.
class CloRulesScreen extends StatefulWidget {
  const CloRulesScreen({super.key});

  @override
  State<CloRulesScreen> createState() => _CloRulesScreenState();
}

class _CloRulesScreenState extends State<CloRulesScreen> {
  final HodService _service = HodService();
  final TextEditingController _searchController = TextEditingController();

  String _session = 'Fall 2026';
  String _exam = 'Final';
  String? _allClos;
  List<HodCourse> _courses = [];

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
    List<HodCourse> courses = await _service.getCourses(
      search: _searchController.text,
    );
    if (!mounted) return;
    setState(() {
      _courses = courses;
    });
  }

  Future<void> _setForAll(String clos) async {
    await _service.setClos(_courses, clos);
    if (!mounted) return;
    setState(() {
      _allClos = clos;
    });
  }

  Future<void> _setForCourse(HodCourse course, String clos) async {
    await _service.setClos([course], clos);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.l,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.m,
                bottom: AppSpacing.l,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/biit_logo.png',
                      width: 36,
                      height: 36,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  const Text(
                    'CLO Rules',
                    style: TextStyle(
                      fontSize: AppFontSize.profileName,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            _buildSearch(),
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                _filterChip(_session, _service.sessions, (v) => _session = v),
                const SizedBox(width: AppSpacing.s),
                _filterChip(_exam, _service.exams, (v) => _exam = v),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            const Text(
              'Select CLO for all subjects',
              style: TextStyle(
                fontSize: AppFontSize.tiny,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            _cloDropdown(
              value: _allClos,
              hint: '-- Select CLO for all Subjects --',
              radius: 100,
              height: 41,
              onChanged: _setForAll,
            ),
            const SizedBox(height: AppSpacing.s),
            _buildListCard(),
          ],
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
    String value,
    List<String> options,
    void Function(String) onChanged,
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
          if (newValue != null) {
            setState(() {
              onChanged(newValue);
            });
          }
        },
      ),
    );
  }

  Widget _cloDropdown({
    required String? value,
    required String hint,
    required double radius,
    required double height,
    required void Function(String) onChanged,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFD7DEDA)),
      ),
      child: DropdownButton<String>(
        value: _service.cloChoices.contains(value) ? value : null,
        hint: Text(hint),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 16),
        style: const TextStyle(
          fontSize: AppFontSize.label,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        items: [
          for (int i = 0; i < _service.cloChoices.length; i++)
            DropdownMenuItem(
              value: _service.cloChoices[i],
              child: Text(
                _service.cloChoices[i],
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }

  Widget _buildListCard() {
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
          Text(
            '${_courses.length} Courses',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          for (int i = 0; i < _courses.length; i++) ...[
            _buildCourseCard(_courses[i]),
            if (i < _courses.length - 1) const SizedBox(height: AppSpacing.s),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseCard(HodCourse course) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.code,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            course.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          const Divider(height: 1, color: Color(0xFFD0EBD2)),
          const SizedBox(height: AppSpacing.s),
          _cloDropdown(
            value: course.clos,
            hint: '-- Select CLOs --',
            radius: 12,
            height: 35,
            onChanged: (value) => _setForCourse(course, value),
          ),
        ],
      ),
    );
  }
}
