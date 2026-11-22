import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../auth/domain/user_model.dart';
import '../../profile/presentation/notifications_screen.dart';
import '../domain/datacell_service.dart';
import '../domain/stats_model.dart';
import 'import_upload_screen.dart';

class DatacellHomeScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;
  final VoidCallback onOpenProfile;
  final VoidCallback onImportDone; // go back to Home tab after an import

  const DatacellHomeScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onOpenProfile,
    required this.onImportDone,
  });

  @override
  State<DatacellHomeScreen> createState() => _DatacellHomeScreenState();
}

class _DatacellHomeScreenState extends State<DatacellHomeScreen> {
  final DatacellService _service = DatacellService();
  StatsModel? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    StatsModel stats = await _service.getStats();
    if (!mounted) return;
    setState(() {
      _stats = stats;
    });
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(role: widget.user.role),
      ),
    );
  }

  Future<void> _openImport() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportUploadScreen(
          onBack: () => Navigator.pop(context),
          onDone: widget.onImportDone,
        ),
      ),
    );
    _loadStats();
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
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    90,
                  ),
                  child: _buildHeroCard(),
                ),
              ),
            ],
          ),
          Positioned(
            right: AppSpacing.xl,
            bottom: AppSpacing.xl,
            child: _buildImportButton(),
          ),
        ],
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/biit_logo.png',
              width: 38,
              height: 38,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'BIIT',
            style: TextStyle(
              fontSize: AppFontSize.profileName,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          _circleButton(Icons.notifications_none, onTap: _openNotifications),
          const SizedBox(width: AppSpacing.m),
          GestureDetector(
            onTapDown: _openMenu,
            child: _circleButton(Icons.more_horiz),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }

  Widget _buildHeroCard() {
    StatsModel? stats = _stats;
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
                      'Welcome, Data Cell Officer',
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
                    'assets/images/avatar_datacell.png',
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
          _buildStatCard(
            icon: Icons.groups_outlined,
            title: 'Total Papers',
            value: stats == null ? '-' : '${stats.total}',
            image: 'assets/images/illus_total_papers.png',
            imageSize: 98,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  title: 'Submitted',
                  value: stats == null ? '-' : '${stats.submitted}',
                  image: 'assets/images/illus_submitted.png',
                  imageSize: 64,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.schedule,
                  title: 'Not Submitted',
                  value: stats == null ? '-' : '${stats.notSubmitted}',
                  image: 'assets/images/illus_not_submitted.png',
                  imageSize: 64,
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String image,
    required double imageSize,
  }) {
    return Container(
      height: 119,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: 12,
            bottom: 12,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(image, width: imageSize, height: imageSize),
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
                          fontSize: AppFontSize.body,
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
                    fontSize: 50,
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

  Widget _buildImportButton() {
    return Material(
      color: AppColors.primary,
      elevation: 6,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: _openImport,
        child: const SizedBox(
          width: 155,
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file, size: 24, color: AppColors.white),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Import Excel',
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
