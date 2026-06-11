import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final token = prefs.getString('auth_token');
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    // KONDISI 1: Jika user sudah login (token ada)
    // ATAU user sudah pernah melewati onboarding sebelumnya (Guest lama)
    if ((token != null && token.isNotEmpty) || hasSeenOnboarding) {
      // Jalankan delay otomatis 2 detik, lalu langsung bypass ke Beranda
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.home);
    }
    // KONDISI 2: Jika benar-benar user baru gres (belum pernah lihat onboarding)
    else {
      // Jangan beri delay otomatis, biarkan halaman diam
      // agar user bisa menikmati UI dan menekan tombol secara manual.
      debugPrint("User baru terdeteksi: Menunggu interaksi tombol.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -80,
            right: -80,
            child: Opacity(
              opacity: 0.06,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Opacity(
              opacity: 0.04,
              child: Container(
                width: 384,
                height: 384,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(top: 48, bottom: 48),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryContainer,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.explore,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
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
                        TextButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool(
                              'has_seen_onboarding',
                              true,
                            ); // Tandai sudah lewat

                            if (!context.mounted) return;
                            Navigator.pushReplacementNamed(
                              context,
                              AppRouter.home,
                            );
                          },
                          child: Text(
                            'Lewati',
                            style: GoogleFonts.beVietnamPro(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Hero image
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCab5BLNB8lSuvAdKfDuh3Xqbu1qeKPIap3ZiWU3fOn5w_Ts3BGMpnxDM6CUIiNwK7j1pfxmI5pJviH_-kKOndlvUGenJoRQ9GzsvOvGjHdPp6JUM3N6gcWHr8zDTfzyJbP_zrxhUjAch0PX3u6iSq9f381Sc5HBhZoomEf6QklvyDrDeH17888Rm88BzIXefeL0A4S2Ro71LTR0xp2jf7xjGEjbXhmjkqbQDiZ27D-GcqLLGcqTyPcAVchXOkDJmJ8kY7Ak4VcKuM',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: AppColors.surfaceContainer,
                                    child: const Icon(
                                      Icons.image,
                                      size: 64,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ),
                              ),
                              // Floating card
                              Positioned(
                                bottom: -16,
                                right: -16,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8EE),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: AppColors.secondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'DESTINASI UTAMA',
                                            style: GoogleFonts.beVietnamPro(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.secondary,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          Text(
                                            'Kraton Surakarta',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurface,
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
                        ),
                        const SizedBox(height: 32),
                        // Typography
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.onSurface,
                                    height: 1.1,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Jelajahi '),
                                    TextSpan(
                                      text: 'Warisan',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                        height: 1.1,
                                      ),
                                    ),
                                    const TextSpan(text: '\nBudaya'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Temukan destinasi wisata bersejarah di jantung Jawa. Rasakan kemegahan Keraton hingga harmoni tradisi yang abadi.',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 16),
                    child: Column(
                      children: [
                        // Progress dots
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryContainer,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // CTA Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            // 1. Ubah menjadi async untuk menyimpan data status onboarding
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              // 2. Kunci status agar di pembukaan aplikasi berikutnya, user langsung bypass ke Home
                              await prefs.setBool('has_seen_onboarding', true);

                              if (!context.mounted) return;

                              // 3. Alihkan navigasi langsung ke halaman Beranda/Home (Bukan login/onboarding)
                              Navigator.pushReplacementNamed(
                                context,
                                AppRouter
                                    .home, // Mengarah ke MainShell / Beranda umum
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            label: Text(
                              'Lanjut',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ],
                    ),
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
