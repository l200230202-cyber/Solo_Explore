import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/theme.dart';
import '../widgets/notification_badge.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _googleMapController;
  LatLng _cameraPosition = const LatLng(-7.5661, 110.8283); 
  bool _isLoadingLocation = true;
  
  // 🟢 Poin 1: Menambahkan state pelacak gestur peta
  bool _mapGestureEnabled = true;

  final Set<Marker> _destinationsMarkers = {
    const Marker(
      markerId: MarkerId('keraton_surakarta'),
      position: LatLng(-7.5777, 110.8282),
      infoWindow: InfoWindow(title: 'Keraton Surakarta', snippet: 'Situs Budaya & Sejarah'),
    ),
    const Marker(
      markerId: MarkerId('pasar_gede'),
      position: LatLng(-7.5676, 110.8319),
      infoWindow: InfoWindow(title: 'Pasar Gede', snippet: 'Pusat Kuliner Tradisional'),
    ),
    const Marker(
      markerId: MarkerId('pura_mangkunegaran'),
      position: LatLng(-7.5663, 110.8242),
      infoWindow: InfoWindow(title: 'Pura Mangkunegaran', snippet: 'Istana Kadipaten Mangkunegaran'),
    ),
  };

  @override
  void initState() {
    super.initState();
    _getUserCurrentLocation();
  }

  Future<void> _getUserCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Layanan GPS Anda dinonaktifkan. Mohon aktifkan GPS!');
      setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Izin akses lokasi ditolak.');
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      LatLng userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _cameraPosition = userLatLng;
        _isLoadingLocation = false;
      });

      _googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 15.0),
      );
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. AREA PETA REAL-TIME
          _isLoadingLocation
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : Positioned.fill(
                  // 🟢 Solusi Web Kuat: AbsorbPointer dinamis membungkus peta agar aman dari kebocoran gesture
                  child: AbsorbPointer(
                    absorbing: !_mapGestureEnabled,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _cameraPosition,
                        zoom: 15.0,
                      ),
                      onMapCreated: (controller) => _googleMapController = controller,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      markers: _destinationsMarkers,
                      mapType: MapType.normal,

                      // 🟢 Poin 2: Mengunci kedaulatan gestur peta via State dinamis
                      scrollGesturesEnabled: _mapGestureEnabled,
                      zoomGesturesEnabled: _mapGestureEnabled,
                      rotateGesturesEnabled: _mapGestureEnabled,
                      tiltGesturesEnabled: _mapGestureEnabled,

                      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                ),

          // Kawung overlay pattern
          Positioned.fill(
            child: IgnorePointer( 
              child: Opacity(
                opacity: 0.03,
                child: CustomPaint(painter: _DotPatternPainter()),
              ),
            ),
          ),

          // Top AppBar Overlay
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              color: const Color(0xFFF5FAF0).withOpacity(0.85),
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

          // Floating search bar
          Positioned(
            top: 100, left: 24, right: 24,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withOpacity(0.9),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1A2E0A).withOpacity(0.08), blurRadius: 32),
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
          
          // Floating Action Buttons (FAB Cluster ditarik naik ke bottom 400 agar tidak tenggelam saat max panel)
          Positioned(
            bottom: 400,
            right: 24,
            child: Column(
              children: [
                _MapFab(
                  icon: Icons.tune, 
                  isPrimary: true,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(24),
                        height: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Filter Destinasi', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Text('Pilih rumpun kategori budaya atau kuliner terdekat wilayah Solo Raya.', style: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _MapFab(
                  icon: Icons.my_location,
                  onTap: _getUserCurrentLocation, 
                ),
              ],
            ),
          ),
          
          // 2. PANEL PUTIH UTAMA (PANEL NYA BISA DI-DRAG ATAS BAWAH DENGAN ELASTIS)
          // 🟢 Poin 3: Membungkus Positioned.fill dengan GestureDetector Pengunci State
          Positioned.fill(
            child: GestureDetector(
              onVerticalDragStart: (_) {
                setState(() {
                  _mapGestureEnabled = false;
                });
              },
              onVerticalDragEnd: (_) {
                setState(() {
                  _mapGestureEnabled = true;
                });
              },
              onVerticalDragCancel: () {
                setState(() {
                  _mapGestureEnabled = true;
                });
              },
              child: DraggableScrollableSheet(
                // 🟢 Poin 5: Konfigurasi snap & ukuran maksimal panel ditingkatkan hingga 0.95 (Hampir Fullscreen)
                initialChildSize: 0.35, 
                minChildSize: 0.15,     
                maxChildSize: 0.95,     
                snap: true,
                snapSizes: const [
                  0.15,
                  0.35,
                  0.95,
                ],
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A2E0A).withOpacity(0.12), 
                          blurRadius: 48, 
                          offset: const Offset(0, -12),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController, 
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              width: 48, height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.outlineVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
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
                                    Text('EKSPLORASI', style: GoogleFonts.beVietnamPro(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondary, letterSpacing: 2)),
                                    Text('Destinasi Terdekat', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                                  ],
                                ),
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, '/search'),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      'Lihat Semua',
                                      style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Mengisolasi khusus area scroll list view card agar stabil mendatar
                          SizedBox(
                            height: 200,
                            child: Listener(
                              onPointerDown: (PointerDownEvent event) {
                                GestureBinding.instance.pointerRouter.route(event);
                              },
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                                physics: const BouncingScrollPhysics(), 
                                children: const [
                                  _NearbyCard(
                                    image: 'https://images.unsplash.com/photo-1596436889106-be35e843f974?q=80&w=400',
                                    name: 'Kampung Batik', rating: '4.8', distance: '1.2km', slug: 'kampung-batik',
                                  ),
                                  _NearbyCard(
                                    image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=400',
                                    name: 'Sate Kere Bu Bagyo', rating: '4.9', distance: '0.8km', slug: 'sate-kere-bu-bagyo',
                                  ),
                                  _NearbyCard(
                                    image: 'https://images.unsplash.com/photo-1626125345510-4603468eedfb?q=80&w=400',
                                    name: 'Pasar Triwindu', rating: '4.7', distance: '2.4km', slug: 'pasar-triwindu',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ), // 🟢 Poin 4: Penutupan kurung ekstra GestureDetector sudah sinkron aman
        ],
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _MapFab({required this.icon, this.isPrimary = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, 
        customBorder: const CircleBorder(),
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primary : AppColors.surfaceContainerLowest,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), 
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(icon, color: isPrimary ? Colors.white : AppColors.primary),
        ),
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  final String image, name, rating, distance, slug;
  
  const _NearbyCard({required this.image, required this.name, required this.rating, required this.distance, required this.slug});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, 
      onTap: () {
        Navigator.pushNamed(context, '/destination-detail', arguments: slug);
      },
      child: Container(
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
                image, height: 96, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(height: 96, color: AppColors.surfaceContainer, child: const Icon(Icons.image, color: AppColors.outline)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFF9FBE7), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 10, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(rating, style: GoogleFonts.beVietnamPro(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('• $distance', style: GoogleFonts.beVietnamPro(fontSize: 9, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary..style = PaintingStyle.fill;
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