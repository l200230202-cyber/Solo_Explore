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
                    child: Icon(Icons.person, size: 40, color: AppColors.primary),
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

            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.home,
              title: 'Beranda',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.explore,
              title: 'Jelajah',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/explore');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.map,
              title: 'Peta',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/map');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.calendar_today,
              title: 'Event',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/event');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.route,
              title: 'Planner',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/planner');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.bookmark,
              title: 'Bookmark',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/bookmark');
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.person,
              title: 'Profil',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),

            const Divider(height: 32),

            // Settings & About
            _buildMenuItem(
              context,
              icon: Icons.settings,
              title: 'Pengaturan',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Pengaturan segera hadir')),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Bantuan',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hubungi kami di support@soloexplore.com')),
                );
              },
            ),

            const Divider(height: 32),

            // Logout
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
                        child: const Text('Keluar', style: TextStyle(color: Colors.red)),
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
            
            // Version
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
              style: GoogleFonts.beVietnamPro(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              '© 2026 Solo Explore',
              style: GoogleFonts.beVietnamPro(
                fontSize: 12,
                color: Colors.grey,
              ),
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
