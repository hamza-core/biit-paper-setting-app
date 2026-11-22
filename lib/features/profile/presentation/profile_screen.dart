import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../auth/domain/user_model.dart';
import '../domain/profile_model.dart';
import '../domain/profile_service.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.user, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _service = ProfileService();
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      ProfileModel profile = await _service.getProfile(widget.user.email);
      if (!mounted) return;
      setState(() {
        _profile = profile;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _openEdit() async {
    ProfileModel? updated = await Navigator.push<ProfileModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: _profile!),
      ),
    );
    if (updated != null) {
      setState(() {
        _profile = updated;
      });
    }
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(role: widget.user.role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ProfileModel? profile = _profile;

    return SafeArea(
      child: profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildProfileCard(profile),
                  const SizedBox(height: AppSpacing.l),
                  _buildSettings(),
                  const SizedBox(height: AppSpacing.l),
                  _buildSignOut(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.l,
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
          Text(
            _service.profileTitle(widget.user.role),
            style: const TextStyle(
              fontSize: AppFontSize.heading,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ProfileModel profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipOval(
              child: Image.asset(
                profile.avatar,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              profile.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppFontSize.profileName,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              profile.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppFontSize.label,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              profile.organization,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppFontSize.label,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            GestureDetector(
              onTap: _openEdit,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.white,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.edit_outlined, size: 14, color: AppColors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preference & Settings',
            style: TextStyle(
              fontSize: AppFontSize.medium,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: AppShadows.card,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.card),
              onTap: _openNotifications,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Text(
                        _service.notificationsLabel(widget.user.role),
                        style: const TextStyle(
                          fontSize: AppFontSize.small,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.greyText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOut() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Material(
        color: AppColors.signOutBackground,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onLogout,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.l),
            alignment: Alignment.center,
            child: const Text(
              'Sign Out from Portal',
              style: TextStyle(
                fontSize: AppFontSize.medium,
                fontWeight: FontWeight.w600,
                color: AppColors.signOutText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
