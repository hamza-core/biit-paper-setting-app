import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/back_circle_button.dart';
import '../../paper_review/domain/paper_review_models.dart';
import '../../paper_review/domain/paper_review_service.dart';
import '../../paper_review/presentation/similarity_sheet.dart';
import '../domain/faculty_models.dart';
import '../domain/faculty_service.dart';
import 'course_status_badge.dart';
import 'covered_topics_screen.dart';
import 'faculty_workspace_screen.dart';

class CourseDetailsScreen extends StatefulWidget {
  final FacultyCourse course;
  final String teacherName; // the logged in teacher

  const CourseDetailsScreen({
    super.key,
    required this.course,
    required this.teacherName,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  final FacultyService _service = FacultyService();
  final PaperReviewService _reviewService = PaperReviewService();

  int _tab = 0; // 0 Teachers, 1 Common Topics, 2 Details
  CoveredTopics? _topics;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    CoveredTopics topics = await _reviewService.getCoveredTopics(
      widget.course.code,
    );
    if (!mounted) return;
    setState(() {
      _topics = topics;
    });
  }

  Future<void> _openTopics() async {
    bool? submitted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CoveredTopicsScreen(
          course: widget.course,
          teacherName: widget.teacherName,
        ),
      ),
    );
    // The teacher list shows who marked their topics, so refresh it.
    if (submitted == true && mounted) {
      setState(() {});
    }
  }

  void _openWorkspace() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacultyWorkspaceScreen(
          course: widget.course,
          teacherName: widget.teacherName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FacultyCourse course = widget.course;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.m,
                  ),
                  child: Row(
                    children: [
                      BackCircleButton(onTap: () => Navigator.pop(context)),
                      const SizedBox(width: AppSpacing.m),
                      const Text(
                        'Course Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.l,
                      AppSpacing.l,
                      AppSpacing.l,
                      190,
                    ),
                    child: Column(
                      children: [
                        _buildHeader(course),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildTabsCard(course),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: AppSpacing.l,
              right: 22,
              bottom: 86,
              child: Row(
                children: [
                  Expanded(
                    child: _whiteButton(
                      Icons.copy_all_outlined,
                      'Check Similarity',
                      () => showSimilaritySheet(context, course.code),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  SizedBox(
                    width: 122,
                    child: _whiteButton(
                      Icons.format_list_bulleted,
                      'Topics',
                      _openTopics,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: AppSpacing.xl,
              bottom: AppSpacing.xl,
              child: Material(
                color: AppColors.primary,
                elevation: 6,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: _openWorkspace,
                  child: const SizedBox(
                    width: 155,
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note, size: 24, color: AppColors.white),
                        SizedBox(width: 6),
                        Text(
                          'Workspace',
                          style: TextStyle(
                            fontSize: AppFontSize.medium,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _whiteButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: AppColors.white,
      elevation: 5,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(width: AppSpacing.s),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppFontSize.medium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(FacultyCourse course) {
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
              Text(
                course.code,
                style: const TextStyle(
                  fontSize: AppFontSize.caption,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              Text(
                'Due: ${course.dueText}',
                style: const TextStyle(
                  fontSize: AppFontSize.label,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            course.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            course.examText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xCCFFFFFF),
            ),
          ),
          const SizedBox(height: 15),
          const Divider(height: 1, color: Color(0x33FFFFFF)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xCCFFFFFF),
                ),
              ),
              CourseStatusBadge(status: course.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabsCard(FacultyCourse course) {
    List<String> labels = ['Teachers', 'Common Topics', 'Details'];
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
                for (int i = 0; i < labels.length; i++) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _tab = i;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _tab == i
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: _tab == i
                                ? AppColors.primary
                                : AppColors.mutedTab,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Container(
                          height: 3,
                          width: labels[i].length * 7.5,
                          decoration: BoxDecoration(
                            color: _tab == i
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < labels.length - 1) const SizedBox(width: 17),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          if (_tab == 0) ..._buildTeachers(course),
          if (_tab == 1) _buildCommon(),
          if (_tab == 2) _buildDetails(),
        ],
      ),
    );
  }

  List<Widget> _buildTeachers(FacultyCourse course) {
    String? waiting = _service.waitingText(course);
    return [
      Text(
        _service.markedText(course),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.greyText,
        ),
      ),
      const SizedBox(height: AppSpacing.m),
      for (int i = 0; i < course.teachers.length; i++) ...[
        _teacherCard(course.teachers[i]),
        const SizedBox(height: AppSpacing.m),
      ],
      if (waiting != null)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Color(0xFF8A6D00),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                waiting,
                style: const TextStyle(
                  fontSize: AppFontSize.caption,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8A6D00),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  Widget _teacherCard(TeacherStatus teacher) {
    Color color = teacher.marked
        ? AppColors.successGreen
        : AppColors.warningText;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.successBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              teacher.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: teacher.marked
                  ? AppColors.successBackground
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  teacher.marked ? Icons.check_circle_outline : Icons.schedule,
                  size: 13,
                  color: color,
                ),
                const SizedBox(width: 5),
                Text(
                  teacher.marked ? 'Marked their topics' : 'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommon() {
    CoveredTopics? topics = _topics;
    if (topics == null) {
      return const Center(child: CircularProgressIndicator());
    }
    List<TopicRow> common = [];
    for (int i = 0; i < topics.rows.length; i++) {
      if (topics.rows[i].coveredByAll) common.add(topics.rows[i]);
    }
    return Column(
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
    );
  }

  Widget _buildDetails() {
    CoveredTopics? topics = _topics;
    if (topics == null) {
      return const Center(child: CircularProgressIndicator());
    }
    const header = TextStyle(
      fontSize: AppFontSize.caption,
      color: AppColors.greyText,
    );
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Text('Topic', style: header)),
            for (int i = 0; i < topics.teacherNames.length; i++)
              SizedBox(
                width: 80,
                child: Text(
                  topics.teacherNames[i],
                  textAlign: TextAlign.center,
                  style: header,
                ),
              ),
          ],
        ),
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
                for (int t = 0; t < topics.rows[r].coveredByTeacher.length; t++)
                  SizedBox(
                    width: 80,
                    child: Center(
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: topics.rows[r].coveredByTeacher[t]
                              ? AppColors.successBackground
                              : const Color(0xFFEFEDE6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          topics.rows[r].coveredByTeacher[t]
                              ? Icons.check
                              : Icons.close,
                          size: 12,
                          color: topics.rows[r].coveredByTeacher[t]
                              ? AppColors.primary
                              : AppColors.greyText,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
