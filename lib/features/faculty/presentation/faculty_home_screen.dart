import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../auth/domain/user_model.dart';
import '../../profile/domain/profile_service.dart';
import '../../profile/presentation/notifications_screen.dart';
import '../domain/faculty_models.dart';
import '../domain/faculty_service.dart';
import 'course_details_screen.dart';
import 'course_status_badge.dart';
import 'trash_screen.dart';
import 'wishlist_screen.dart';

class FacultyHomeScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;
  final VoidCallback onOpenProfile;
  final VoidCallback onViewAllPapers;

  const FacultyHomeScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onOpenProfile,
    required this.onViewAllPapers,
  });

  @override
  State<FacultyHomeScreen> createState() => _FacultyHomeScreenState();
}

class _FacultyHomeScreenState extends State<FacultyHomeScreen> {
  final FacultyService _service = FacultyService();

  FacultyStats? _stats;
  List<FacultyCourse> _courses = [];
  bool _hasUnread = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    FacultyStats stats = await _service.getStats();
    List<FacultyCourse> courses = await _service.getCourses();
    List notifications = await ProfileService().getNotifications(
      widget.user.role,
    );
    bool unread = false;
    for (int i = 0; i < notifications.length; i++) {
      if (notifications[i].isUnread) unread = true;
    }
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _courses = courses;
      _hasUnread = unread;
    });
  }

  Future<void> _openMenu(TapDownDetails details) async {
    String? choice = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        0,
        0,
      ),
      items: const [
        PopupMenuItem(
          value: 'profile',
          child: _MenuRow(Icons.person_outline, 'Profile'),
        ),
        PopupMenuItem(
          value: 'wishlist',
          child: _MenuRow(Icons.favorite_border, 'Wishlist'),
        ),
        PopupMenuItem(
          value: 'trash',
          child: _MenuRow(Icons.delete_outline, 'Trash'),
        ),
        PopupMenuItem(
          value: 'logout',
          child: _MenuRow(Icons.logout, 'Log out'),
        ),
      ],
    );
    if (!mounted) return;
    if (choice == 'profile') widget.onOpenProfile();
    if (choice == 'logout') widget.onLogout();
    if (choice == 'wishlist') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WishlistScreen()),
      );
    }
    if (choice == 'trash') {
      // The trash of all my courses
      List papers = await _service.getAllPapers(widget.user.name);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrashScreen(papers: List.from(papers)),
        ),
      );
    }
  }

  void _openCourse(FacultyCourse course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CourseDetailsScreen(course: course, teacherName: widget.user.name),
      ),
    );
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
          children: [
            _buildTopBar(),
            const SizedBox(height: AppSpacing.xl),
            _buildHeroCard(),
            const SizedBox(height: AppSpacing.xl),
            _buildActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
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
        const Text(
          'BIIT',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationsScreen(role: widget.user.role),
              ),
            );
          },
          child: SizedBox(
            width: 44,
            height: 40,
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                if (_hasUnread)
                  Positioned(
                    right: 4,
                    top: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53935),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        GestureDetector(
          onTapDown: _openMenu,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    FacultyStats? stats = _stats;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x21000000),
            blurRadius: 14,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${widget.user.name}',
                      style: const TextStyle(
                        fontSize: AppFontSize.label,
                        fontWeight: FontWeight.w500,
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x33FFFFFF), width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/avatar_faculty.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          _buildSessionCard(),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  Icons.menu_book_outlined,
                  'My Courses',
                  stats == null ? '-' : '${stats.courses}',
                  'assets/images/fac_courses.png',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statCard(
                  Icons.description_outlined,
                  'Papers to Set',
                  stats == null ? '-' : '${stats.papersToSet}',
                  'assets/images/fac_papers.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Session',
                  style: TextStyle(
                    fontSize: AppFontSize.tiny,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greyText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Fall 2026 - Final Term',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.successGreen,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String title, String value, String image) {
    return Container(
      height: 133,
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 37,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                image,
                width: 93,
                height: 89,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Icon(icon, size: 14, color: const Color(0xCCFFFFFF)),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivities() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: widget.onViewAllPapers,
                child: Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'View all Papers',
                    style: TextStyle(
                      fontSize: AppFontSize.caption,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          for (int i = 0; i < _courses.length; i++) ...[
            FacultyCourseCard(
              course: _courses[i],
              onTap: () => _openCourse(_courses[i]),
            ),
            if (i < _courses.length - 1) const SizedBox(height: AppSpacing.m),
          ],
        ],
      ),
    );
  }
}

// One row of the faculty menu.
class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.m),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

// Card of a course: code, status badge, name and a chevron.
class FacultyCourseCard extends StatelessWidget {
  final FacultyCourse course;
  final VoidCallback onTap;

  const FacultyCourseCard({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  course.code,
                  style: const TextStyle(
                    fontSize: AppFontSize.caption,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                CourseStatusBadge(status: course.status),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: AppFontSize.small,
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
      ),
    );
  }
}
