import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelGuideScreen extends StatelessWidget {
  const LevelGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Panduan Leveling',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tingkatan Solo Explore',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              'Jelajahi tempat baru, kumpulkan poin, dan naikkan levelmu!',
              style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha((255 * 0.08).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Setiap kenaikan 1 level membutuhkan 1000 poin.',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withAlpha((255 * 0.3).round()),
                ),
              ),
              child: Column(
                children: [
                  _buildLevelInfoRow(
                    '1 - 2',
                    'Beginner Explorer',
                    'Level awal setiap penjelajah baru.',
                    Colors.grey,
                  ),
                  _buildLevelInfoRow(
                    '3 - 4',
                    'Active Explorer',
                    'Sering jalan-jalan dan aktif explore.',
                    Colors.blue,
                  ),
                  _buildLevelInfoRow(
                    '5 - 6',
                    'Expert Explorer',
                    'Sudah menjelajahi banyak tempat seru.',
                    Colors.orange,
                  ),
                  _buildLevelInfoRow(
                    '7 - 9',
                    'Veteran Traveler',
                    'Penjelajah tangguh yang tahu banyak rute.',
                    Colors.purple,
                  ),
                  _buildLevelInfoRow(
                    '10+',
                    'Master Explorer',
                    'Gelar tertinggi para Solo Explorer!',
                    Colors.amber,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Cara Mendapatkan Poin',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            _buildHowToGetPointItem(
              Icons.map_rounded,
              'Kunjungi Tempat',
              'Datang dan jelajahi lokasi baru (+50 Poin)',
            ),

            _buildHowToGetPointItem(
              Icons.rate_review_rounded,
              'Berikan Ulasan',
              'Bagikan pengalamanmu di kolom komentar (+30 Poin)',
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Row(
                        children: [
                          const Icon(Icons.share, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Segera Hadir',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        'Fitur Share Level sedang dikembangkan.\n\nNantinya kamu bisa membagikan level, poin, dan pencapaianmu ke media sosial.',
                        style: GoogleFonts.beVietnamPro(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Oke'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.share_outlined),
                label: Text(
                  'Bagikan Level Saya',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelInfoRow(
    String range,
    String name,
    String desc,
    Color badgeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 55,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha((255 * 0.15).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'LV $range',
              textAlign: TextAlign.center,
              style: GoogleFonts.beVietnamPro(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToGetPointItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha((255 * 0.1).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 11,
                    color: Colors.grey[600],
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
