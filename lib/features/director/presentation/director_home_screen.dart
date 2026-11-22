import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../auth/domain/user_model.dart';
import '../../profile/presentation/notifications_screen.dart';
import '../domain/director_models.dart';
import '../domain/director_service.dart';
import 'paper_card.dart';

class DirectorHomeScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;
  final VoidCallback onOpenProfile;
  final void Function(DirectorPaper paper) onOpenPaper;

  const DirectorHomeScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onOpenProfile,
    required this.onOpenPaper,
  });

  @override
  State<DirectorHomeScreen> createState() => _DirectorHomeScreenState();
}

class _DirectorHomeScreenState extends State<DirectorHomeScreen> {
  final DirectorService _service = DirectorService();

  DirectorStats? _stats;
  List<DirectorPaper> _papers = [];
  String _tab = 'toReview';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    DirectorStats stats = await _service.getStats();
    List<DirectorPaper> papers = await _service.getPapers(
      archived: false,
      statusFilter: _tab,
    );
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _papers = papers;
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
        PopupMenuItem(value: 'profile', child: Text('Profile')),
        PopupMenuItem(value: 'logout', child: Text('Log out')),
      ],
    );
    if (choice == 'profile') widget.onOpenProfile();
    if (choice == 'logout') widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.m,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        child: Column(
          children: [
            _buildBrandRow(),
            const SizedBox(height: 14),
            _buildHeroCard(),
            const SizedBox(height: 14),
            _buildPapersCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandRow() {
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
        CircleIconButton(
          icon: Icons.notifications_none,
          iconSize: 22,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NotificationsScreen(role: widget.user.role),
              ),
            );
          },
        ),
        const SizedBox(width: AppSpacing.m),
        GestureDetector(
          onTapDown: _openMenu,
          child: const CircleIconButton(icon: Icons.more_horiz),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    DirectorStats? stats = _stats;
    String total = stats == null ? '-' : '${stats.total}';
    String submitted = stats == null ? '-' : '${stats.submitted}';
    String notSubmitted = stats == null ? '-' : '${stats.notSubmitted}';
    String approved = stats == null ? '-' : '${stats.approved}';
    double progress = (stats == null || stats.total == 0)
        ? 0
        : stats.submitted / stats.total;

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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Director',
                      style: TextStyle(
                        fontSize: AppFontSize.label,
                        fontWeight: FontWeight.w500,
                        color: Color(0xCCFFFFFF),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
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
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/avatar_director.jpg',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildSessionCard(),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  Icons.description_outlined,
                  'Total Papers',
                  total,
                  'assets/images/dir_total.png',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoCard(
                  Icons.check_circle_outline,
                  'Submitted Papers',
                  submitted,
                  'assets/images/dir_submitted.png',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _infoCard(
                  Icons.schedule,
                  'Not Submitted',
                  notSubmitted,
                  'assets/images/dir_not_submitted.png',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoCard(
                  Icons.description_outlined,
                  'Approved Papers',
                  approved,
                  'assets/images/dir_approved.png',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildProgressCard(stats, progress),
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

  Widget _infoCard(IconData icon, String title, String value, String image) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.heroCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -4,
            bottom: -5,
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                image,
                width: 52,
                height: 46,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Icon(icon, size: 12, color: const Color(0xCCFFFFFF)),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w600,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(DirectorStats? stats, double progress) {
    int waiting = stats == null ? 0 : stats.total - stats.submitted;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.heroCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Finalterm submissions',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              Text(
                stats == null ? '-' : '${stats.submitted}/${stats.total}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.primary,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$waiting papers awaiting submission',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPapersCard() {
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
            children: [
              _tabItem('To Review', 'toReview'),
              const SizedBox(width: AppSpacing.xl),
              _tabItem('Approved', 'approved'),
              const SizedBox(width: AppSpacing.xl),
              _tabItem('Not Submitted', 'notSubmitted'),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          if (_papers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.l),
              child: Center(child: Text('No papers here')),
            ),
          for (int i = 0; i < _papers.length; i++) ...[
            DirectorPaperCard(
              paper: _papers[i],
              onAction: () => _paperAction(_papers[i]),
            ),
            if (i < _papers.length - 1) const SizedBox(height: AppSpacing.m),
          ],
        ],
      ),
    );
  }

  Widget _tabItem(String label, String value) {
    bool selected = _tab == value;
    return GestureDetector(
      onTap: () {
        _tab = value;
        _load();
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.primary : AppColors.mutedTab,
            ),
          ),
          const SizedBox(height: 3),
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
}
