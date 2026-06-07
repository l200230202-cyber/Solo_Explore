import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class BadgeCard extends StatelessWidget {
  final String name;
  final String description;
  final String icon;
  final bool isEarned;
  final VoidCallback? onTap;

  const BadgeCard({
    super.key,
    required this.name,
    required this.description,
    required this.icon,
    this.isEarned = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEarned ? AppColors.primaryContainer : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEarned ? AppColors.primary : AppColors.outlineVariant,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isEarned ? AppColors.primary : AppColors.outline,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isEarned ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.beVietnamPro(
                fontSize: 11,
                color: isEarned ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isEarned) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Terbuka',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
