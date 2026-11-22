import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../domain/auth_service.dart';
import '../domain/user_model.dart';

class LoginScreen extends StatefulWidget {
  // Called when login works, so main.dart can save token and role.
  final void Function(UserModel user) onLoggedIn;

  const LoginScreen({super.key, required this.onLoggedIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _hidePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });
    try {
      UserModel user = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );
      widget.onLoggedIn(user);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      setState(() {
        _loading = false;
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
              AppSpacing.xxl + AppSpacing.s,
              AppSpacing.screenPadding,
              AppSpacing.xxl,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 56,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/biit_logo.png',
                        width: 191,
                        height: 191,
                      ),
                      const SizedBox(height: AppSpacing.l),
                      const Text(
                        'WELCOME BACK',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFontSize.title,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      const Text(
                        'Sign in to your dashboard',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFontSize.subtitle,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: Icons.mail_outline,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        obscureText: _hidePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textDark,
                          ),
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const Spacer(),
                      _loading
                          ? const SizedBox(
                              height: 51,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : AppButton(text: 'Sign in', onPressed: _signIn),
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
}
