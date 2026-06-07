import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showMenu;
  final bool showBack;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBackTap;

  const AppTopBar({
    super.key,
    this.showMenu = true,
    this.showBack = false,
    this.onMenuTap,
    this.onBackTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5FAF0).withValues(alpha: 0.85),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (showBack)
                    GestureDetector(
                      onTap: onBackTap ?? () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: AppColors.primary),
                    )
                  else if (showMenu)
                    GestureDetector(
                      onTap: onMenuTap,
                      child: const Icon(Icons.menu, color: AppColors.primary),
                    ),
                  const SizedBox(width: 12),
                  Text(
                    'SoloExplore',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.notifications_outlined, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
