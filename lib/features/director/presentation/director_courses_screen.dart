import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../domain/director_models.dart';
import '../domain/director_service.dart';

class DirectorCoursesScreen extends StatefulWidget {
  const DirectorCoursesScreen({super.key});

  @override
  State<DirectorCoursesScreen> createState() => _DirectorCoursesScreenState();
}

class _DirectorCoursesScreenState extends State<DirectorCoursesScreen> {
  final DirectorService _service = DirectorService();
  final TextEditingController _searchController = TextEditingController();

  String _department = 'All';
  List<CourseModel> _courses = [];
  String? _expandedCode; // only one card is open at a time

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
    List<CourseModel> courses = await _service.getCourses(
      search: _searchController.text,
      department: _department,
    );
    if (!mounted) return;
    setState(() {
      _courses = courses;
    });
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
                const Text(
                  'Courses',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildSearch(),
            const SizedBox(height: 14),
            _buildChips(),
            const SizedBox(height: 14),
            Text(
              '${_courses.length} courses shown',
              style: const TextStyle(
                fontSize: AppFontSize.small,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            for (int i = 0; i < _courses.length; i++) ...[
              _buildCourseCard(_courses[i]),
              if (i < _courses.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _load(),
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search courses by name or code...',
          hintStyle: TextStyle(fontSize: 14, color: AppColors.inactiveTab),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: AppColors.inactiveTab,
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 30),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildChips() {
    return Wrap(
      spacing: 6,
      children: [
        for (int i = 0; i < _service.departments.length; i++)
          _chip(_service.departments[i]),
      ],
    );
  }

  Widget _chip(String department) {
    bool selected = _department == department;
    String label = department == 'All' ? 'All' : '$department Department';
    return GestureDetector(
      onTap: () {
        _department = department;
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: selected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    bool expanded = _expandedCode == course.code;
    int count = course.teachers.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _expandedCode = expanded ? null : course.code;
              });
            },
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    course.code,
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.name,
                        style: const TextStyle(
                          fontSize: AppFontSize.small,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count == 1 ? '1 teacher' : '$count teachers',
                        style: const TextStyle(
                          fontSize: AppFontSize.label,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  expanded ? 'Hide ' : 'Show ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 14),
            for (int i = 0; i < course.teachers.length; i++) ...[
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.successBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _service.initials(course.teachers[i]),
                      style: const TextStyle(
                        fontSize: AppFontSize.caption,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    course.teachers[i],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              if (i < course.teachers.length - 1) const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}
