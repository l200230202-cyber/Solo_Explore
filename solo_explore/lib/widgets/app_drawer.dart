import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/storage_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Solo Explore',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Eksplorasi Pesona Solo Raya',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Menu Items (Hanya Tentang Aplikasi & Bantuan)
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                _showAboutDialog(context); // Tampilkan dialog Tentang
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Bantuan',
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                _showHelpDialog(context); // Tampilkan dialog Bantuan baru
              },
            ),

            const Divider(height: 32),

            // Logout / Keluar
            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: 'Keluar',
              textColor: Colors.red,
              onTap: () async {
                final navigator = Navigator.of(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Keluar'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await StorageService().clearToken();
                  navigator.pushReplacementNamed('/login');
                }
              },
            ),

            const SizedBox(height: 16),

            // Version Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.beVietnamPro(
          fontSize: 16,
          color: textColor ?? Colors.black87,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  // DIALOG TENTANG APLIKASI
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tentang Solo Explore',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Solo Explore',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aplikasi panduan wisata untuk menjelajahi pesona Solo Raya. Temukan destinasi wisata, kuliner, dan event menarik di Solo.',
              style: GoogleFonts.beVietnamPro(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Version: 1.0.0',
              style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '© 2026 Solo Explore',
              style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // DIALOG BANTUAN KUSTOM BARU
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Pusat Bantuan',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Butuh Bantuan?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jika Anda mengalami kendala penggunaan aplikasi, kritik, atau saran, silakan hubungi tim dukungan kami.',
              style: GoogleFonts.beVietnamPro(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'support@soloexplore.com',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
