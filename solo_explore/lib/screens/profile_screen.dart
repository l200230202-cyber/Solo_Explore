import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../core/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _myBadges = [];
  List<Map<String, dynamic>> _availableRewards = [];
  List<Map<String, dynamic>> _visits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await ApiService().getProfile();
      final stats = await ApiService().getStats();
      final badges = await ApiService().getMyBadges();
      final rewards = await ApiService().getAvailableRewards();
      final visits = await ApiService().getVisits();

      if (mounted) {
        setState(() {
          _profile = profile;
          _stats = stats;
          _myBadges = badges;
          _availableRewards = rewards;
          _visits = visits;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    if (_profile == null) return;

    final nameController = TextEditingController(text: _profile!['name']);
    final phoneController = TextEditingController(text: _profile!['phone'] ?? '');
    final bioController = TextEditingController(text: _profile!['bio'] ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: const OutlineInputBorder(),
                  labelStyle: GoogleFonts.beVietnamPro(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: const OutlineInputBorder(),
                  labelStyle: GoogleFonts.beVietnamPro(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: const OutlineInputBorder(),
                  labelStyle: GoogleFonts.beVietnamPro(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.beVietnamPro()),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ApiService().updateProfile({
                'name': nameController.text,
                'phone': phoneController.text,
                'bio': bioController.text,
              });
              if (context.mounted) {
                Navigator.pop(context, success);
              }
            },
            child: Text('Simpan', style: GoogleFonts.beVietnamPro()),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile berhasil diupdate'), backgroundColor: Colors.green),
      );
      _loadData();
    }
  }

  Future<void> _claimReward(int id, String name) async {
    final success = await ApiService().claimReward(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name berhasil diklaim!'), backgroundColor: Colors.green),
      );
      _loadData();
    }
  }

  String _getLevelName(int level) {
    if (level >= 10) return 'Master Explorer';
    if (level >= 7) return 'Veteran Traveler';
    if (level >= 5) return 'Expert Explorer';
    if (level >= 3) return 'Active Explorer';
    return 'Beginner Explorer';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonthName(int month) {
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return months[month];
  }

  IconData _getBadgeIcon(String iconName) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userName = _profile?['name'] ?? 'User';
    final userLevel = _profile?['level'] ?? 1;
    final userPoints = _stats?['points'] ?? 0;
    final totalDestinations = _stats?['total_destinations'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFFF5FAF0).withValues(alpha: 0.9),
            elevation: 0,
            title: Text(
              'SoloExplore',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: _showEditProfileDialog,
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.primary),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Logout', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                      content: Text('Apakah Anda yakin ingin keluar?', style: GoogleFonts.beVietnamPro()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Batal', style: GoogleFonts.beVietnamPro()),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: Text('Logout', style: GoogleFonts.beVietnamPro()),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true && context.mounted) {
                    await ApiService().logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route) => false);
                    }
                  }
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            ClipOval(
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuALz8oOoANW_5nZDrN09JfhYK12eJ1-RnSCOXJ32As4-RiOeYZ51LfD_J0JFPvgbvWmbObs6ONlpFDb5A-nD4dR-Eqp9JC_KsEEm9lwZnic1tlvt--KcBNBSMNtlsStqmpuAq2c5LcFgHRg-sXvsaBX-b16G-AAVvPtxCqfMawZk-JV980OOH0No7JTBpxLy1Xu3nCr0U-68dewLRz1fiYnryZzg7pB_vbzHMtlbuSMmlpI0Oqa29qfeG_5D80BD4N4WYHai4xP5VQ',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 80,
                                  height: 80,
                                  color: AppColors.surfaceContainer,
                                  child: const Icon(Icons.person, size: 40, color: AppColors.outline),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.verified, color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                _profile?['bio'] ?? 'Solo Explorer',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      'LEVEL $userLevel',
                                      style: GoogleFonts.beVietnamPro(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getLevelName(userLevel),
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total Points',
                          value: '$userPoints',
                          sub: '+${_stats?['points_this_month'] ?? 0} this month',
                          subIcon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: 'Destinations',
                          value: '$totalDestinations',
                          sub: 'Surakarta & Solo Raya',
                          subIcon: Icons.location_on,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Reward milestone
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reward Milestone',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  '250 points to unlock Free Batik Workshop',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRouter.rewards),
                              child: const Icon(Icons.arrow_forward, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: 0.8,
                            minHeight: 12,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _availableRewards.isEmpty
                              ? Text(
                                  'Tidak ada reward yang bisa diklaim',
                                  style: GoogleFonts.beVietnamPro(fontSize: 12),
                                )
                              : Column(
                                  children: _availableRewards.take(2).map((reward) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: const BoxDecoration(
                                              color: AppColors.secondaryContainer,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.redeem, color: AppColors.onSecondaryContainer),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'CLAIMABLE REWARD',
                                                  style: GoogleFonts.beVietnamPro(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.onSecondaryContainer,
                                                  ),
                                                ),
                                                Text(
                                                  reward['name'] ?? 'Reward',
                                                  style: GoogleFonts.beVietnamPro(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.onSurface,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => _claimReward(reward['id'], reward['name']),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              shape: const StadiumBorder(),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text(
                                              'Klaim',
                                              style: GoogleFonts.beVietnamPro(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Visit history
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Riwayat Kunjungan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Show all visits in a dialog or navigate to a full screen
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Semua Riwayat Kunjungan',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                              ),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: _visits.isEmpty
                                    ? const Center(child: Text('Belum ada riwayat kunjungan'))
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _visits.length,
                                        itemBuilder: (context, index) {
                                          final visit = _visits[index];
                                          final isDestination = visit['destination'] != null;
                                          String? slug;
                                          if (isDestination) {
                                            slug = visit['destination']?['slug'] as String?;
                                          } else {
                                            slug = visit['culinary']?['slug'] as String?;
                                          }
                                          final routeName = isDestination ? '/destination' : '/culinary';
                                          
                                          return ListTile(
                                            leading: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                visit['destination']?['image'] ?? visit['culinary']?['image'] ?? '',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: AppColors.surfaceContainer,
                                                  child: const Icon(Icons.image, color: AppColors.outline),
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              visit['destination']?['name'] ?? visit['culinary']?['name'] ?? 'Unknown',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              _formatDate(visit['visited_at']),
                                              style: GoogleFonts.beVietnamPro(fontSize: 12),
                                            ),
                                            trailing: Text(
                                              '+${visit['points_earned'] ?? 0} pts',
                                              style: GoogleFonts.beVietnamPro(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              if (slug != null) {
                                                Navigator.pushNamed(context, routeName, arguments: slug);
                                              }
                                            },
                                          );
                                        },
                                      ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'Lihat Semua',
                              style: GoogleFonts.beVietnamPro(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._visits.take(3).map((visit) {
                    final isDestination = visit['destination'] != null;
                    final slug = isDestination 
                        ? (visit['destination']?['slug']) 
                        : (visit['culinary']?['slug']);
                    final routeName = isDestination ? '/destination' : '/culinary';
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          if (slug != null) {
                            Navigator.pushNamed(context, routeName, arguments: slug);
                          }
                        },
                        child: _VisitCard(
                          image: visit['destination']?['image'] ?? visit['culinary']?['image'] ?? '',
                          name: visit['destination']?['name'] ?? visit['culinary']?['name'] ?? 'Unknown',
                          date: _formatDate(visit['visited_at']),
                          rating: '${visit['destination']?['rating'] ?? visit['culinary']?['rating'] ?? 0}',
                          comment: visit['notes'] ?? 'Kunjungan tercatat',
                          points: '+${visit['points_earned'] ?? 0} pts',
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  // Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Badges Terkoleksi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRouter.badges),
                        child: Row(
                          children: [
                            Text(
                              'Lihat Semua',
                              style: GoogleFonts.beVietnamPro(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: _myBadges.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada badge',
                              style: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _myBadges.length,
                            itemBuilder: (context, index) {
                              final badge = _myBadges[index];
                              return _BadgeItem(
                                icon: _getBadgeIcon(badge['icon'] ?? 'star'),
                                label: badge['name'] ?? 'Badge',
                                isActive: true,
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData subIcon;
  const _StatCard({required this.label, required this.value, required this.sub, required this.subIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.beVietnamPro(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(subIcon, size: 12, color: AppColors.primary),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  sub,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final String image, name, date, rating, comment, points;
  const _VisitCard({
    required this.image,
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Image.network(
              image,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 96,
                height: 96,
                color: AppColors.surfaceContainer,
                child: const Icon(Icons.image, color: AppColors.outline),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          points,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 12, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xFFF2C94C)),
                      const SizedBox(width: 2),
                      Text(
                        rating,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        comment,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  const _BadgeItem({required this.icon, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.3,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isActive ? AppColors.cream : AppColors.outlineVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppColors.secondaryContainer : AppColors.outline,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: isActive ? AppColors.secondary : AppColors.outline,
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 64,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
