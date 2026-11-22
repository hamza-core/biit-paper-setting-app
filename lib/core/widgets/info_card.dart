import 'package:flutter/material.dart';

import '../design_tokens.dart';

// Small stat card inside the green dashboard card
// (title with icon, big number, faded picture in the corner).
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String image;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.heroCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -4,
            bottom: -5,
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                image,
                width: 52,
                height: 46,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Icon(icon, size: 12, color: const Color(0xCCFFFFFF)),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: AppFontSize.tiny,
                          fontWeight: FontWeight.w600,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 25,
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
}
