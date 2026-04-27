import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class LevelProgressBar extends StatelessWidget {
  final int currentLevel;
  final int currentXP;
  final int nextLevelXP;
  final bool showLabel;

  const LevelProgressBar({
    super.key,
    required this.currentLevel,
    required this.currentXP,
    required this.nextLevelXP,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = nextLevelXP > 0 ? currentXP / nextLevelXP : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $currentLevel',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                '$currentXP / $nextLevelXP XP',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryFixedDim],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
