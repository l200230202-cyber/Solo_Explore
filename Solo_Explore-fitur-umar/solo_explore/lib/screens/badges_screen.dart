import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<Map<String, dynamic>> _allBadges = [];
  List<Map<String, dynamic>> _myBadges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final allBadges = await ApiService().getBadges();
      final myBadges = await ApiService().getMyBadges();

      if (mounted) {
        setState(() {
          _allBadges = allBadges;
          _myBadges = myBadges;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _hasBadge(int badgeId) {
    return _myBadges.any((b) => b['id'] == badgeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Badges',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _allBadges.length,
              itemBuilder: (context, index) {
                final badge = _allBadges[index];
                final hasIt = _hasBadge(badge['id']);
                
                return _BadgeCard(
                  name: badge['name'] ?? 'Badge',
                  description: badge['description'] ?? '',
                  icon: _getIcon(badge['icon'] ?? 'star'),
                  isUnlocked: hasIt,
                  requirement: badge['requirement'] ?? '',
                );
              },
            ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'temple': return Icons.temple_buddhist;
      case 'restaurant': return Icons.restaurant;
      case 'camera': return Icons.camera_alt;
      case 'hiking': return Icons.hiking;
      case 'star': return Icons.star;
      case 'trophy': return Icons.emoji_events;
      default: return Icons.workspace_premium;
    }
  }
}

class _BadgeCard extends StatelessWidget {
  final String name, description, requirement;
  final IconData icon;
  final bool isUnlocked;

  const _BadgeCard({
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.requirement,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? AppColors.primary : AppColors.outline,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUnlocked ? AppColors.secondaryContainer : AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isUnlocked ? AppColors.secondary : AppColors.outline,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isUnlocked) ...[
              const SizedBox(height: 4),
              Text(
                requirement,
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 9,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
