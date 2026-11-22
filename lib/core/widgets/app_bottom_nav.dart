import 'package:flutter/material.dart';

import '../design_tokens.dart';

// One tab of the bottom bar.
class NavItem {
  final String label;
  final IconData icon;

  NavItem({required this.label, required this.icon});
}

// White floating bottom bar with rounded corners (as in Figma).
class AppBottomNav extends StatelessWidget {
  final List<NavItem> items;
  final int currentIndex;
  final void Function(int index) onTap;

  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          0,
          AppSpacing.l,
          AppSpacing.l,
        ),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [for (int i = 0; i < items.length; i++) _buildItem(i)],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    bool selected = index == currentIndex;
    Color color = selected ? AppColors.primary : AppColors.inactiveTab;
    return InkWell(
      onTap: () => onTap(index),
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(items[index].icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              items[index].label,
              style: TextStyle(
                fontSize: AppFontSize.tiny,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
