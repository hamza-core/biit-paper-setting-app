import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/profile_model.dart';
import '../domain/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _service = ProfileService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  late TextEditingController _designationController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _departmentController = TextEditingController(
      text: widget.profile.department,
    );
    _designationController = TextEditingController(
      text: widget.profile.designation,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
    });
    ProfileModel updated = ProfileModel(
      email: widget.profile.email, // email is the login id, so it stays
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _departmentController.text.trim(),
      designation: _designationController.text.trim(),
      subtitle: widget.profile.subtitle,
      organization: widget.profile.organization,
      avatar: widget.profile.avatar,
    );
    try {
      await _service.saveProfile(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.l,
              AppSpacing.screenPadding,
              AppSpacing.xxl + AppSpacing.s,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildAvatar(),
                      AppTextField(
                        label: 'Full Name',
                        hint: 'Enter your name',
                        icon: Icons.person_outline,
                        controller: _nameController,
                        textSize: AppFontSize.medium,
                        iconColor: AppColors.primary,
                        validator: _required,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      // Email is the login id so it cannot be edited.
                      AppTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: Icons.mail_outline,
                        controller: _emailController,
                        textSize: AppFontSize.medium,
                        iconColor: AppColors.greyText,
                        readOnly: true,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      AppTextField(
                        label: 'Phone',
                        hint: 'Enter your phone',
                        icon: Icons.phone_outlined,
                        controller: _phoneController,
                        textSize: AppFontSize.medium,
                        iconColor: AppColors.primary,
                        validator: _required,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      AppTextField(
                        label: 'Department',
                        hint: 'Enter your department',
                        icon: Icons.apartment_outlined,
                        controller: _departmentController,
                        textSize: AppFontSize.medium,
                        iconColor: AppColors.primary,
                        validator: _required,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      AppTextField(
                        label: 'Designation',
                        hint: 'Enter your designation',
                        icon: Icons.workspace_premium_outlined,
                        controller: _designationController,
                        textSize: AppFontSize.medium,
                        iconColor: AppColors.primary,
                        validator: _required,
                      ),
                      const Spacer(),
                      const SizedBox(height: 40),
                      _saving
                          ? const SizedBox(
                              height: 51,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : AppButton(text: 'Save Changes', onPressed: _save),
                      const SizedBox(height: 18),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: AppFontSize.medium,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyText,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l, bottom: AppSpacing.l),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: AppShadows.card,
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 22,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: AppFontSize.profileName,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.m, bottom: AppSpacing.xxl),
      child: Center(
        child: SizedBox(
          width: 92,
          height: 92,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.asset(
                  widget.profile.avatar,
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.5),
                  ),
                  child: const Icon(
                    Icons.no_photography_outlined,
                    size: 14,
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
