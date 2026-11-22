import 'package:flutter/material.dart';

import '../design_tokens.dart';

// Square checkbox from the Figma design.
// state: 0 = empty, 1 = some selected (shows "-"), 2 = all selected (tick).
class AppCheckbox extends StatelessWidget {
  final int state;
  final VoidCallback? onTap;
  final double size;
  final bool faded; // used for sub-topics that follow their parent

  const AppCheckbox({
    super.key,
    required this.state,
    this.onTap,
    this.size = 20,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    bool filled = state != 0;
    Widget box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(size > 16 ? 6 : 3),
        border: Border.all(
          color: filled ? AppColors.primary : const Color(0xFF7A7A7A),
          width: 1.5,
        ),
      ),
      child: state == 2
          ? Icon(Icons.check, size: size * 0.6, color: AppColors.white)
          : state == 1
          ? Icon(Icons.remove, size: size * 0.7, color: AppColors.white)
          : null,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: faded ? Opacity(opacity: 0.5, child: box) : box,
    );
  }
}
