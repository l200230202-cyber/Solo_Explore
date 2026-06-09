import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../core/app_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _stats;

  bool _isLoading = true;
  bool _isPublicMode = false;

  // 🛠️ PERBAIKAN: Ambil level dari data _stats (mengikuti struktur Laravel stats)
  int get userLevel {
    return int.tryParse(_stats?['level']?.toString() ?? '1') ?? 1;
  }

  String get userName {
    return _profile?['name']?.toString() ?? 'Pengguna';
  }

  // 🛠️ PERBAIKAN: Ambil total poin dari data _stats
  int get userPoints {
    return int.tryParse(_stats?['points']?.toString() ?? '0') ?? 0;
  }

  // 🛠️ PERBAIKAN: Ambil total destinasi dari data _stats
  String get totalDestinations {
    return _stats?['total_destinations']?.toString() ?? '0';
  }

  // 🛠️ TAMBAHAN: Mengambil gelar level langsung dari database Laravel jika ada
  String get levelTitle {
    return _stats?['level_title']?.toString() ?? _getLevelName(userLevel);
  }

  // 🛠️ TAMBAHAN: Mengambil list riwayat kunjungan dari objek _stats
  List<dynamic> get visitsHistory {
    return _stats?['visits_history'] as List<dynamic>? ?? [];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 2. PERBARUI FUNGSI LOAD DATA DENGAN CEK TOKEN
Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Cek status login via ApiService
      final bool isLoggedIn = await ApiService().hasToken();

      if (!isLoggedIn) {
        if (mounted) {
          setState(() {
            _isPublicMode = true;
            _isLoading = false;
          });
        }
        return; // Stop di sini jika user adalah Guest/Tamu
      }

      // 🛠️ PANGGIL PARALEL: Hanya profile dan stats saja dari Laravel
      final profile = await ApiService().getProfile();
      final stats = await ApiService().getStats();

      // Baris ApiService().getVisits() Dihapus dari sini 🗑️

      if (mounted) {
        setState(() {
          _profile = profile;
          _stats = stats;
          // Baris _visits = ... Dihapus dari sini 🗑️
          _isPublicMode = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    if (_profile == null) return;

    final nameController = TextEditingController(text: _profile!['name']);
    final phoneController = TextEditingController(
      text: _profile!['phone'] ?? '',
    );
    final bioController = TextEditingController(text: _profile!['bio'] ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
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
        const SnackBar(
          content: Text('Profile berhasil diupdate'),
          backgroundColor: Colors.green,
        ),
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

  @override
  Widget build(BuildContext context) {
    // 1. Jika masih loading, tampilkan indikator loading
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // 2. JIKA MODE PUBLIC (TAMU / BELUM LOGIN)
    if (_isPublicMode) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  size: 80,
                  color: AppColors.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'Yuk, Masuk Akun dulu!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk untuk melihat riwayat kunjungan, mengoleksi badges, dan menukarkan poin menarik.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    // Berpindah ke halaman login
                    Navigator.pushNamed(context, AppRouter.login);
                  },
                  child: Text(
                    'Login Sekarang',
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    

    return VisibilityDetector(
      key: const Key('profile_screen_key'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 1.0 &&
            !_isLoading &&
            !_isPublicMode) {
          _loadData();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: const Color(0xFFF5FAF0).withValues(alpha: 0.9),
              elevation: 0,
              title: Text(
                'SoloExplore',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              actions: [
                // 🛠️ TOMBOL EDIT PROFIL
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: _showEditProfileDialog,
                ),
                // 🛠️ TOMBOL LOGOUT (SUDAH DIGABUNG KEMBALI)
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.primary),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Logout',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        content: Text(
                          'Apakah Anda yakin ingin keluar?',
                          style: GoogleFonts.beVietnamPro(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.beVietnamPro(),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(
                              'Logout',
                              style: GoogleFonts.beVietnamPro(),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await ApiService().logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.login,
                          (route) => false,
                        );
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
                                  child: const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppColors.outline,
                                  ),
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
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                  size: 14,
                                ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
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
                          sub:
                              '+${_stats?['points_this_month'] ?? 0} this month',
                          subIcon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: 'Destinations',
                          value: totalDestinations,
                          sub: 'Surakarta & Solo Raya',
                          subIcon: Icons.location_on,
                        ),
                      ),
                    ],
                  ),
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
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Semua Riwayat Kunjungan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              content: SizedBox(
                                width: double.maxFinite,
                                child:
                                    visitsHistory
                                        .isEmpty // 🛠️ Menggunakan getter baru
                                    ? const Center(
                                        child: Text(
                                          'Belum ada riwayat kunjungan',
                                        ),
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: visitsHistory
                                            .length, // 🛠️ Menggunakan getter baru
                                        itemBuilder: (context, index) {
                                          final visit = visitsHistory[index];
                                          final slug = visit['slug'] as String?;
                                          final routeName =
                                              visit['type'] == 'Destination'
                                              ? '/destination'
                                              : '/culinary';

                                          return ListTile(
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                visit['image'] ??
                                                    '', // 🛠️ Struktur Laravel baru langsung menggunakan 'image'
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      width: 50,
                                                      height: 50,
                                                      color: AppColors
                                                          .surfaceContainer,
                                                      child: const Icon(
                                                        Icons.image,
                                                        color:
                                                            AppColors.outline,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                            title: Text(
                                              visit['name'] ??
                                                  'Unknown', // 🛠️ Struktur Laravel baru langsung menggunakan 'name'
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            subtitle: Text(
                                              visit['visited_at'] ??
                                                  '', // 🛠️ Tanggal sudah diformat rapi dari Laravel
                                              style: GoogleFonts.beVietnamPro(
                                                fontSize: 12,
                                              ),
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
                                                Navigator.pushNamed(
                                                  context,
                                                  routeName,
                                                  arguments: slug,
                                                );
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
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 🛠️ MAPPING HALAMAN UTAMA (MAKSIMAL 3 RIWAYAT TERBARU)
                  if (visitsHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Belum ada riwayat kunjungan',
                          style: GoogleFonts.beVietnamPro(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...visitsHistory.take(3).map((visit) {
                      final slug = visit['slug'] as String?;
                      final routeName = visit['type'] == 'Destination'
                          ? '/destination'
                          : '/culinary';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            if (slug != null) {
                              Navigator.pushNamed(
                                context,
                                routeName,
                                arguments: slug,
                              );
                            }
                          },
                          child: _VisitCard(
                            image:
                                visit['image'] ??
                                '', // 🛠️ Struktur bersih dari Laravel
                            name:
                                visit['name'] ??
                                'Unknown', // 🛠️ Struktur bersih dari Laravel
                            date:
                                visit['visited_at'] ??
                                '', // 🛠️ Struktur bersih dari Laravel
                            rating: '', // 🛠️ Rating belum tersedia di Laravel, bisa ditambahkan nanti
                            comment: visit['notes'] ?? 'Berhasil dikunjungi',
                            points: '+${visit['points_earned'] ?? 0} pts',
                          ),
                        ),
                      );
                    },),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData subIcon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.subIcon,
  });

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
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
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
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
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
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.primary,
                      ),
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
