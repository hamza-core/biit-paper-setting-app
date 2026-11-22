import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/circle_icon_button.dart';
import '../../../core/widgets/info_card.dart';
import '../../auth/domain/user_model.dart';
import '../../director/domain/director_models.dart';
import '../../director/domain/director_service.dart';
import '../../director/presentation/paper_card.dart';
import '../../profile/presentation/notifications_screen.dart';
import '../domain/hod_models.dart';
import '../domain/hod_service.dart';
import 'assign_paper_screen.dart';

class HodHomeScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;
  final VoidCallback onOpenProfile;
  final VoidCallback onViewAllPapers;
  final void Function(DirectorPaper paper) onOpenPaper;

  const HodHomeScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onOpenProfile,
    required this.onViewAllPapers,
    required this.onOpenPaper,
  });

  @override
  State<HodHomeScreen> createState() => _HodHomeScreenState();
}

class _HodHomeScreenState extends State<HodHomeScreen> {
  final HodService _service = HodService();
  final DirectorService _paperService = DirectorService();

  HodStats? _stats;
  List<DirectorPaper> _papers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    HodStats stats = await _service.getStats();
    List<DirectorPaper> papers = await _paperService.getPapers(
      archived: false,
      statusFilter: 'toReview',
      cloPending: true,
    );
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _papers = papers;
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
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.m,
                  AppSpacing.xl,
                  14,
                ),
                child: _buildBrandRow(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    90,
                  ),
                  child: Column(
                    children: [
                      _buildHeroCard(),
                      const SizedBox(height: AppSpacing.l),
                      _buildActivitiesCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 19,
            bottom: AppSpacing.l,
            child: _buildAssignButton(),
          ),
        ],
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
    HodStats? stats = _stats;
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
                      'HOD Dashboard',
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
                  border: Border.all(
                    color: const Color(0x33FFFFFF),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/avatar_hod.jpg',
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
          InfoCard(
            icon: Icons.description_outlined,
            title: 'Submitted Papers / Papers need to CLO review',
            value: stats == null ? '-' : '${stats.needReview}',
            image: 'assets/images/hod_review.png',
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  icon: Icons.description_outlined,
                  title: 'Total Papers',
                  value: stats == null ? '-' : '${stats.total}',
                  image: 'assets/images/hod_total.png',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InfoCard(
                  icon: Icons.schedule,
                  title: 'Not Submitted',
                  value: stats == null ? '-' : '${stats.notSubmitted}',
                  image: 'assets/images/hod_not_submitted.png',
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

  Widget _buildActivitiesCard() {
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
          const SizedBox(height: AppSpacing.s),
          if (_papers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.l),
              child: Center(child: Text('No papers waiting for review')),
            ),
          for (int i = 0; i < _papers.length; i++) ...[
            DirectorPaperCard(
              paper: _papers[i],
              onAction: () => widget.onOpenPaper(_papers[i]),
            ),
            if (i < _papers.length - 1) const SizedBox(height: AppSpacing.m),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignButton() {
    return Material(
      color: AppColors.primary,
      elevation: 6,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AssignPaperScreen()),
          );
        },
        child: const SizedBox(
          width: 155,
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_add_outlined, size: 22, color: AppColors.white),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Assign Paper',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFontSize.medium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
