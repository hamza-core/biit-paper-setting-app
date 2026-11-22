import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../domain/hod_models.dart';
import '../domain/hod_service.dart';

class AssignPaperScreen extends StatefulWidget {
  const AssignPaperScreen({super.key});

  @override
  State<AssignPaperScreen> createState() => _AssignPaperScreenState();
}

class _AssignPaperScreenState extends State<AssignPaperScreen> {
  final HodService _service = HodService();
  final TextEditingController _searchController = TextEditingController();

  int _semester = 0; // 0 = All
  List<HodCourse> _courses = [];
  List<String> _teachers = [];

  // What the HOD picked for each course before pressing Assign / Change.
  final Map<String, DateTime?> _pickedDates = {};
  final Map<String, String?> _pickedTeachers = {};

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
      semester: _semester,
    );
    List<String> teachers = await _service.getTeachers();
    if (!mounted) return;
    setState(() {
      _courses = courses;
      _teachers = teachers;
    });
  }

  DateTime? _dateOf(HodCourse course) {
    return _pickedDates.containsKey(course.code)
        ? _pickedDates[course.code]
        : course.dueDate;
  }

  String? _teacherOf(HodCourse course) {
    return _pickedTeachers.containsKey(course.code)
        ? _pickedTeachers[course.code]
        : course.teacher;
  }

  Future<void> _pickDate(HodCourse course) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOf(course) ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _pickedDates[course.code] = picked;
      });
    }
  }

  Future<void> _assign(HodCourse course) async {
    try {
      await _service.assignPaper(course, _dateOf(course), _teacherOf(course));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${course.name} assigned to ${course.teacher}')),
      );
      setState(() {
        _pickedDates.remove(course.code);
        _pickedTeachers.remove(course.code);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl,
                vertical: AppSpacing.l,
              ),
              child: Row(
                children: [
                  BackCircleButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: AppSpacing.m),
                  const Text(
                    'Assign Paper',
                    style: TextStyle(
                      fontSize: AppFontSize.heading,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  0,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearch(),
                    const SizedBox(height: AppSpacing.l),
                    _buildChips(),
                    const SizedBox(height: AppSpacing.l),
                    _buildListCard(),
                  ],
                ),
              ),
            ),
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

  Widget _buildChips() {
    return Wrap(
      spacing: 6,
      children: [
        _chip('All', 0),
        for (int i = 0; i < _service.semesters.length; i++)
          _chip('Semester ${_service.semesters[i]}', _service.semesters[i]),
      ],
    );
  }

  Widget _chip(String label, int value) {
    bool selected = _semester == value;
    return GestureDetector(
      onTap: () {
        _semester = value;
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
    DateTime? date = _dateOf(course);
    String? teacher = _teacherOf(course);
    bool assigned = course.isAssigned;

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
          Divider(
            height: 1,
            color: assigned ? const Color(0xFFD0EBD2) : AppColors.border,
          ),
          const SizedBox(height: AppSpacing.s),
          GestureDetector(
            onTap: () => _pickDate(course),
            child: Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date == null
                        ? '-- Select Date --'
                        : _service.dateText(date),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: date == null
                          ? const Color(0xFF6B7280)
                          : AppColors.textDark,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.textDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD7DEDA)),
                  ),
                  child: DropdownButton<String>(
                    value: teacher,
                    hint: const Text('-- Select Teacher --'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                    style: const TextStyle(
                      fontSize: AppFontSize.label,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    items: [
                      for (int i = 0; i < _teachers.length; i++)
                        DropdownMenuItem(
                          value: _teachers[i],
                          child: Text(
                            _teachers[i],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _pickedTeachers[course.code] = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              GestureDetector(
                onTap: () => _assign(course),
                child: Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assigned ? 'Change' : 'Assign',
                    style: const TextStyle(
                      fontSize: AppFontSize.label,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
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
