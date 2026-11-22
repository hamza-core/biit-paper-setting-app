import 'package:flutter/material.dart';

import '../design_tokens.dart';

// Round white back button used in screen headers.
class BackCircleButton extends StatelessWidget {
  final VoidCallback onTap;

  const BackCircleButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
        child: const Icon(
          Icons.chevron_left,
          size: 22,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
