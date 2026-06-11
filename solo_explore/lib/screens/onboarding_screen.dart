import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCab5BLNB8lSuvAdKfDuh3Xqbu1qeKPIap3ZiWU3fOn5w_Ts3BGMpnxDM6CUIiNwK7j1pfxmI5pJviH_-kKOndlvUGenJoRQ9GzsvOvGjHdPp6JUM3N6gcWHr8zDTfzyJbP_zrxhUjAch0PX3u6iSq9f381Sc5HBhZoomEf6QklvyDrDeH17888Rm88BzIXefeL0A4S2Ro71LTR0xp2jf7xjGEjbXhmjkqbQDiZ27D-GcqLLGcqTyPcAVchXOkDJmJ8kY7Ak4VcKuM',
      title: 'Jelajahi Warisan Budaya',
      subtitle: 'Temukan destinasi wisata bersejarah di jantung Jawa.',
      location: 'Kraton Surakarta',
    ),
    _OnboardingData(
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAN4BoRTd8joZUO7SnzczTR15dS08oeMLkWq88iu4funurtqabViO5Qa_I6to_fm9RpR8CxYmC3X9BtrrQZPZcnmwIeUy0h4eItLNQxUiABULtcwxV-XeYyOTTroc9Q1Zz9VfmPQKTf-lZ3dNijQ-dBbotLFoE_z-Dm3Z0hZ9jaMtaFR2GP1KneMWs9dPS29caOZJRR9pYykO5M9hK1gnuVyqy1WyiahVDmIurZvaU1avfbcE0vdzwCpSn7cxMsL4crayE2q2whdqA',
      title: 'Nikmati Alam Indah',
      subtitle: 'Dari air terjun Grojogan Sewu hingga kebun teh Kemuning.',
      location: 'Tawangmangu, Karanganyar',
    ),
    _OnboardingData(
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAf6RLLPnik1xlvEelHuq988l5Tnva8FRjGlUzXjQQyB9m-qfTWkoOyv1qa-irLqarE5c4yrrffYU2duLP25RoNqFZPPU0U7GdjANf_WL0RpEwfCkQHC3DVV2qj47Wa6seF6oCbqPK9-6Hqlwjt5B3SOblNemtSUFXgsGaBzMOLnYsFB_rLeNEKR3BN3hEO4VTuu2MTFldH4CPFIJT_tdG5ni5ngQRjCNr3rzF7vY-zrZdhaI4hHoEBesL2l4F6IBXO7z7a8ax1IPU',
      title: 'Kuliner',
      subtitle: 'Rasakan cita rasa autentik Nasi Liwet, Selat Solo, dan Serabi.',
      location: 'Kota Surakarta',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) => _OnboardingPage(data: _pages[index]),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                            colors: [AppColors.primary, AppColors.primaryContainer],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.explore, color: Colors.white, size: 18),
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
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.home),
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
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: Column(
                  children: [
                    // Progress dots
                    Row(
                      children: List.generate(_pages.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: i == _currentPage ? 32 : 8,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? AppColors.primary
                                : AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (_currentPage < _pages.length - 1) {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            final navigator = Navigator.of(context);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('has_seen_onboarding', true);
                            navigator.pushReplacementNamed(AppRouter.login);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        label: Text(
                          _currentPage < _pages.length - 1 ? 'Lanjut' : 'Mulai Jelajah',
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
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String image, title, subtitle, location;
  const _OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.location,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 100, 32, 160),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    data.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.surfaceContainer,
                      child: const Icon(Icons.image, size: 64, color: AppColors.outline),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -16,
                  right: -16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8EE),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                              data.location,
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
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.subtitle,
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
    );
  }
}
