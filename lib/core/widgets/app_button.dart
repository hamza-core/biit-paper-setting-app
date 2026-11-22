import 'package:flutter/material.dart';

import '../design_tokens.dart';

// Big dark green button used on most screens.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  // compact = the smaller button used inside forms and dialogs
  final bool compact;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    bool disabled = onPressed == null;
    return Container(
      height: compact ? 49 : 51,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: compact ? null : AppShadows.soft,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.disabledButton,
          disabledForegroundColor: AppColors.greyText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: compact ? AppFontSize.medium : AppFontSize.button,
            fontWeight: compact ? FontWeight.w700 : FontWeight.w400,
            color: disabled ? AppColors.greyText : AppColors.white,
          ),
        ),
      ),
    );
  }
}
