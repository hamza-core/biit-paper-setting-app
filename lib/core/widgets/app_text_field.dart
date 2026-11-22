import 'package:flutter/material.dart';

import '../design_tokens.dart';

// White rounded input with a label on top and an icon on the left.
class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffix;
  final double textSize;
  final bool readOnly;
  final Color iconColor;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.suffix,
    this.textSize = AppFontSize.body,
    this.readOnly = false,
    this.iconColor = AppColors.textDark,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppFontSize.small,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.soft,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            readOnly: readOnly,
            validator: validator,
            style: TextStyle(
              fontSize: textSize,
              fontWeight: textSize == AppFontSize.body
                  ? FontWeight.w400
                  : FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: AppFontSize.body,
                color: AppColors.hint,
              ),
              prefixIcon: Icon(icon, color: iconColor),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
