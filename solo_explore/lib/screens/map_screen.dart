import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart'
    as http; // Ditambahkan untuk koneksi ke API Laravel
import '../core/theme.dart';
import '../widgets/notification_badge.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isLoadingLocation = false;
  bool _isLoadingDestinations = false;
  String _currentLocationText = "Lokasi belum dideteksi";
  List<dynamic> _nearbyDestinations = [];

  // Fungsi instan untuk mengambil lokasi GPS terkini
  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // 1. Cek apakah layanan GPS di HP aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _currentLocationText = "GPS HP kamu mati, tolong nyalakan";
        });
        return;
      }

      // 2. Cek Izin
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _currentLocationText = "Izin lokasi ditolak";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _currentLocationText = "Izin lokasi ditolak permanen";
        });
        return;
      }

      // 3. Ambil Lokasi
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _isLoadingLocation = false;
        _currentLocationText =
            "Koordinat: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
      });

      // Proteksi async gap sebelum memanggil fungsi context/API selanjutnya
      if (!mounted) return;

      // 4. Tembak API Laravel untuk mencari destinasi terdekat
      _fetchNearbyDestinations(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _currentLocationText = "Error: $e";
      });
    }
  }

  // Fungsi untuk mengambil data destinasi terdekat dari Backend Laravel
  Future<void> _fetchNearbyDestinations(double lat, double lng) async {
    setState(() {
      _isLoadingDestinations = true;
    });

    // Catatan URL Endpoint:
    // Gunakan '10.0.2.2' jika menggunakan emulator Android bawaan Google
    // Gunakan IP lokal Wi-Fi laptopmu (misal '192.168.1.x') jika testing dengan HP fisik
    final String url =
        'http://192.168.0.4:8000/api/destinations/nearby?lat=$lat&lng=$lng';

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _nearbyDestinations = responseData['data'];
          _isLoadingDestinations = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lokasi berhasil diperbarui! Menampilkan destinasi terdekat.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        throw Exception('Gagal memuat data dari server');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDestinations = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal tersambung ke server backend: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5FAF0).withValues(alpha: 0.85),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 24),
            child: NotificationBadge(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Pola Kawung Tradisional
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
          ),

          // Konten Utama
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 1. Floating Search Bar
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest.withValues(
                      alpha: 0.9,
                    ),
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
                          hintStyle: GoogleFonts.beVietnamPro(
                            color: AppColors.onSurfaceVariant,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Tombol Deteksi Lokasi Terkini
                Card(
                  elevation: 0,
                  color: AppColors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: _isLoadingLocation ? null : _fetchCurrentLocation,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ubah teks dinamis berdasarkan status loading API / GPS
                                Text(
                                  _isLoadingDestinations
                                      ? "Memproses Data Wisata..."
                                      : "Gunakan Lokasi Saat Ini",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isLoadingLocation
                                      ? "Mencari koordinat GPS..."
                                      : _currentLocationText,
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isLoadingLocation || _isLoadingDestinations)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          else
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.outline,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Header Judul Eksplorasi
                Row(
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
                const SizedBox(height: 16),

                // 4. List Destinasi Terdekat (Dinamis dari Backend Laravel)
                Expanded(
                  child: _isLoadingDestinations
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : _nearbyDestinations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Ketuk tombol di atas untuk memuat\ndestinasi di sekitar Anda',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.beVietnamPro(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: _nearbyDestinations.length,
                          itemBuilder: (context, index) {
                            final dest = _nearbyDestinations[index];

                            // 🟢 1. Bungkus dengan InkWell agar kartu bisa diklik
                            return InkWell(
                             onTap: () {
                                // 🟢 AMBIL DATA SLUG, BUKAN ID
                                final destinationSlug = dest['slug'];

                                if (destinationSlug != null) {
                                  // Karena app_router Anda menggunakan konfigurasi pushNamed,
                                  // mari kita kirim slug tersebut sebagai argument murni.
                                  Navigator.pushNamed(
                                    context,
                                    '/destination',
                                    arguments: destinationSlug
                                        .toString(), // Kirim string slug (contoh: "waduk-cengklik")
                                  );
                                } else {
                                  debugPrint(
                                    "Peringatan: Slug destinasi tidak ditemukan!",
                                  );
                                }
                              },
                              // Berikan efek splash yang rapi mengikuti bentuk card jika diperlukan
                              borderRadius: BorderRadius.circular(12),

                              // Tetap panggil fungsi UI Card bawaan Anda
                              child: _buildVerticalNearbyCard(
                                image: dest['image'] ?? '',
                                name: dest['name'] ?? '-',
                                rating: (dest['rating'] ?? 0.0).toString(),
                                distance: dest['distance'] ?? '- km',
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk membuat kartu list mengalir vertikal
  Widget _buildVerticalNearbyCard({
    required String image,
    required String name,
    required String rating,
    required String distance,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
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
              height: 80,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 80,
                width: 100,
                color: AppColors.surfaceContainer,
                child: const Icon(Icons.image, color: AppColors.outline),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 10,
                              color: AppColors.secondary,
                            ),
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
                      const SizedBox(width: 8),
                      Text(
                        '• Jarak: $distance',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
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
