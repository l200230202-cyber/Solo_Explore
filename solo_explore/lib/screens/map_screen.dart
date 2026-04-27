import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../widgets/notification_badge.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map background
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAaf0b3DgkedLrWJvkoxADu1By294q8LkPKTUMNj45sUOLPZ0Wj9JAYKxcQpV9QpZJAi34NBXT5FuKna1QmymlSjbOxVUAcJt1bd6m8TP8UbnRIr5Xz9Xc4z1cf7Ix8GMebSjfOKjfNzwNnnqP5beSBBuCYxtavLfZSj83hhDU-RM6XNGvC_49NHdT-R7NGo_Wc-feyFWEKYs6QDN2Q3JnGHFZgMMcXz00Y-JQjP3DoMU-LyiQ4qxPOHrEMN6TrfDNdKIQHi5sBGW4',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: AppColors.surfaceContainerLow),
            ),
          ),
          // Kawung overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
          ),
          // Top AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
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
                          const Icon(Icons.menu, color: AppColors.primary),
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
                      const NotificationBadge(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Map pins
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.25,
            child: _MapPin(label: 'Keraton Surakarta'),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: MediaQuery.of(context).size.width * 0.6,
            child: _MapPin(label: 'Pasar Gede'),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.55,
            left: MediaQuery.of(context).size.width * 0.45,
            child: _MapPin(label: 'Pura Mangkunegaran'),
          ),
          // Floating search bar
          Positioned(
            top: 100,
            left: 24,
            right: 24,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A2E0A).withValues(alpha: 0.08),
                    blurRadius: 32,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/search'),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari destinasi budaya...',
                      hintStyle: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // FAB cluster
          Positioned(
            bottom: 280,
            right: 24,
            child: Column(
              children: [
                _MapFab(icon: Icons.tune, isPrimary: true),
                const SizedBox(height: 12),
                _MapFab(icon: Icons.my_location),
              ],
            ),
          ),
          // Bottom sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A2E0A).withValues(alpha: 0.12),
                    blurRadius: 48,
                    offset: const Offset(0, -12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EKSPLORASI',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'Destinasi Terdekat',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/search'),
                          child: Text(
                            'Lihat Semua',
                            style: GoogleFonts.beVietnamPro(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      children: [
                        _NearbyCard(
                          image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDonqseUO33lSTzvI-s-sBuZLceQbDG3IExrIXrNsjrMPLuxnrr4RlGV96y69cVvwp1AuuZ1GbqmxsunqMFyK_0kC4BUGTE7Z1asuf6RnaHgjjoAOknxchoBAtKvrgvD8xiUGrRYpANNge5oSlOSd0sm6Evpg79gM-kZKRnz96wGXjsp7PCRM6kFEINiof21IkeeVQaUCbKi6IyiGkYrXW5krZ8Lr-HDFQACbrMpWxwCIRQYV_2k1f3jh6Kw1PJxngWsterFQJ6QRM',
                          name: 'Kampung Batik',
                          rating: '4.8',
                          distance: '1.2km',
                        ),
                        _NearbyCard(
                          image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBRK3jJECixU4a8GiEW7TSKDhwWXlxLfraD4baOTIqQRFb_0zHOCoNXJdqQU_AEdwsUc1BaEoFj99B3Vf4VtzFemqsfFfOItD6jBq-tMLGiPtL2J4K0ZT7sI4VOGXB71l9IEKXR1XsXO7xPJsummB9O2EBlVZA4mjajRNF4big3J2LDzp5fYj4LVS33063RjprE-gEuSFfDmF-TmjGxi3OSWO509FE9LgUwXyLmo16kZSG-JXAgwauIRWtdpkr_8luKHpsDnCB-Vqw',
                          name: 'Sate Kere Bu Bagyo',
                          rating: '4.9',
                          distance: '0.8km',
                        ),
                        _NearbyCard(
                          image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBIwpuv062WxDMjsgzigpkJy_NBcoZe0FpUGY1TAJ9R2Tw3MvA1pzcd7Go0riCG_fzLgk-a8BNor-PU3E7iorevGJtBil8wjnGMgFxWYBMBu2VTeBxvpxmyZGOPTEsO5NgQ_P1UuxnBZljbCgwAFJCS8xsQEAq_Tz5IV5B4YfbSDBU-mgRi5S9HdlAa5Amey77LxAKDJuSFJhI7ow2V_Y8hqnPvhx3y8_GeEOznZlX22f1-DFkaippg95h4SGHIPBDj_XcyxHCHEY8',
                          name: 'Pasar Triwindu',
                          rating: '4.7',
                          distance: '2.4km',
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

class _MapPin extends StatelessWidget {
  final String label;
  const _MapPin({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final bool isPrimary;
  const _MapFab({required this.icon, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
      child: Icon(
        icon,
        color: isPrimary ? Colors.white : AppColors.primary,
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  final String image, name, rating, distance;
  const _NearbyCard({
    required this.image,
    required this.name,
    required this.rating,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              image,
              height: 96,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 96,
                color: AppColors.surfaceContainer,
                child: const Icon(Icons.image, color: AppColors.outline),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 10, color: AppColors.secondary),
                          const SizedBox(width: 2),
                          Text(
                            rating,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• $distance',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 9,
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
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
