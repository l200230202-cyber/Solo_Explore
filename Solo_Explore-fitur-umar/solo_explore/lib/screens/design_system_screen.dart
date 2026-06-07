import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          // Top batik watermark
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: _BatikPattern(opacity: 0.06),
          ),
          // Bottom batik watermark
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: _BatikPattern(opacity: 0.06, flipVertical: true),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo circle
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 32,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.explore,
                    color: AppColors.primary,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'SoloExplore',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryContainer,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'EKSPLORASI PESONA SOLO RAYA',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 80),
                // Progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.33,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bottom card peek
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: AppColors.surfaceContainer,
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuB0N_RDsX9vGvHB3ZUfMmJEbulhISoqPQuLu0KVNhH-xxSB_eb8v7WNHn4RyqqA2jmwxpT_KfsR9H01l4ChQ1VEJWEJjmELAZKaNXI77O2P_IuKRYEiFvCmWasyKycqLOw7ejHkEy1c1GJ2jPmVkBztnIcKnX_G7uX21doSTDNsPSbft6zrtBoyPLg6Q8aOZFEVJDBz28ZD8OlAWXGn3LhnEL5m7o9QpqRbIaF7PFTJGDCzdiczN8LIDvWwPBNzSgX4O6nVPsL0_nM',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(Icons.image, color: AppColors.outline),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HERITAGE',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'Keraton Surakarta',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
                  ],
                ),
              ),
            ),
          ),
          // Footer
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              'Surakarta • Sukoharjo • Karanganyar • Boyolali • Sragen • Wonogiri • Klaten',
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BatikPattern extends StatelessWidget {
  final double opacity;
  final bool flipVertical;
  const _BatikPattern({this.opacity = 0.05, this.flipVertical = false});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleY: flipVertical ? -1 : 1,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.transparent],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: Opacity(
          opacity: opacity,
          child: CustomPaint(
            painter: _KawungPainter(),
          ),
        ),
      ),
    );
  }
}

class _KawungPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    const step = 60.0;
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        canvas.drawCircle(Offset(x, y), 12, paint..color = AppColors.primary.withValues(alpha: 0.05));
        canvas.drawCircle(Offset(x + step / 2, y + step / 2), 12, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
