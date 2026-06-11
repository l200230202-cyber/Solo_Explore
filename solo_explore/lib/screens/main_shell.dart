import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/auth_required_screen.dart'; // 1. Impor halaman pengunci yang dibuat tadi
import '../services/api_service.dart'; // Impor api_service untuk cek token
import 'home_screen.dart';
import 'map_screen.dart';
import 'planner_screen.dart';
import 'event_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // 2. Hapus keyword 'const' dan variabel '_screens' statis di sini
  // karena kita akan membuatnya dinamis di dalam method build.

  @override
  Widget build(BuildContext context) {
    // 3. Ambil status apakah token kosong (Guest) atau ada
    // Sembari memanggil fungsi pengecekan token dari ApiService milikmu
    final bool isGuest =
        ApiService().token == null || ApiService().token!.isEmpty;

    // 4. Racik daftar halaman secara dinamis berdasarkan status login
    final List<Widget> dynamicScreens = [
      const HomeScreen(), // Index 0: Beranda (Public)
      const MapScreen(), // Index 1: Peta (Public)
      // Index 2: Planner (DIKUNCI)
      isGuest
          ? const AuthRequiredScreen(
              title: 'Rencanakan Liburanmu',
              description:
                  'Fitur Trip Planner hanya tersedia untuk member Solo Explore. Yuk login untuk mulai menyusun jadwal perjalanan serumu!',
              icon: Icons.calendar_month_rounded,
            )
          : const PlannerScreen(),

      const EventScreen(), // Index 3: Event (Public)
      // Index 4: Profil (DIKUNCI)
      isGuest
          ? const AuthRequiredScreen(
              title: 'Akses Profil Terkunci',
              description:
                  'Masuk dengan akunmu untuk melihat statistik perjalanan, total poin, pencapaian level, dan pengaturan akun.',
              icon: Icons.account_circle_rounded,
            )
          : const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: dynamicScreens, // 5. Masukkan list dinamis ke sini
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
