import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class NotificationBadge extends StatefulWidget {
  const NotificationBadge({super.key});

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await ApiService().getUnreadNotificationCount();
      if (mounted) {
        setState(() => _unreadCount = count);
      }
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/notifications').then((_) {
          // Reload count after returning from notifications screen
          _loadUnreadCount();
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Stack(
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 24,
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
