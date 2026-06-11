import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../models/destination.dart';
import '../models/culinary.dart';
import '../models/category.dart';
import '../widgets/notification_badge.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  List<Destination> _destinations = [];
  List<Culinary> _culinaries = [];
  List<dynamic> _recommendations = [];
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final apiService = ApiService();

      final categories = await apiService.getCategories();

      // 2. Ambil data profil user yang sedang login untuk tahu minatnya
      String? userInterest;
      try {
        final Map<String, dynamic>? userProfile = await apiService.getProfile();
        debugPrint('Profil mentah: $userProfile');
        if (userProfile != null &&
            userProfile['interests'] != null &&
            (userProfile['interests'] as List).isNotEmpty) {
          userInterest = userProfile['interests'][0]['slug'];
        }
      } catch (authError) {
        debugPrint('User is guest or failed to fetch profile: $authError');
      }

      // 🛠️ TAMBAHKAN KONDISI INI: Jika null, beri fallback biar list tidak kosong
      if (userInterest == null) {
        debugPrint(
          'DEBUG: userInterest null, menggunakan fallback "wisata-alam"',
        );
        userInterest =
            'wisata-alam'; // Sesuaikan dengan slug yang pasti ada di databasemu
      }

      // 3. Ambil data rekomendasi dinamis lewat fungsi baru kita di api_service
      final recommendations = await apiService.getPersonalizedRecommendations(
        userInterest,
      );
      debugPrint('===[ DEBUG REKOMENDASI ]===');
      debugPrint('Nilai slug userInterest: $userInterest');
      debugPrint('Jumlah data didapat: ${recommendations.length}');
      if (recommendations.isNotEmpty) {
        debugPrint(
          'Tipe data objek pertama: ${recommendations.first.runtimeType}',
        );
      }
      debugPrint('===========================');

      final destinations = await apiService.getDestinations();
      final culinaries = await apiService.getCulinaries();

      if (mounted) {
        setState(() {
          _categories = categories;
          _recommendations = recommendations; // 🎯 Masukkan ke sini!
          _destinations = destinations;
          _culinaries = culinaries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _filterByCategory(String? categorySlug) async {
    setState(() {
      _selectedCategory = categorySlug;
      _isLoading = true;
    });

    try {
      final apiService = ApiService();

      if (categorySlug == null) {
        String? userInterest;
        try {
          final userProfile = await apiService.getProfile();
          if (userProfile != null &&
              userProfile['interests'] != null &&
              (userProfile['interests'] as List).isNotEmpty) {
            userInterest = userProfile['interests'][0]['slug'];
          }
        } catch (_) {}

        final recommendations = await apiService.getPersonalizedRecommendations(
          userInterest,
        );
        final destinations = await apiService.getDestinations();
        final culinaries = await apiService.getCulinaries();

        if (mounted) {
          setState(() {
            _recommendations = recommendations;
            _destinations = destinations;
            _culinaries = culinaries;
            _isLoading = false;
          });
        }
      } else if (categorySlug == 'kuliner') {
        final culinaries = await apiService.getCulinaries();
        if (mounted) {
          setState(() {
            _recommendations = culinaries;
            _destinations = [];
            _culinaries = culinaries;
            _isLoading = false;
          });
        }
      } else {
        final destinations = await apiService.getDestinations(
          category: categorySlug,
        );
        final culinaries = await apiService.getCulinaries();
        if (mounted) {
          setState(() {
            _recommendations = destinations;
            _destinations = destinations;
            _culinaries = culinaries;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFFF5FAF0).withValues(alpha: 0.9),
            elevation: 0,
            title: Text(
              'SoloExplore',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.primary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: const [NotificationBadge()],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //search bar
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/search'),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.search, color: AppColors.primary),
                          ),
                          Text(
                            'Mau kemana hari ini?',
                            style: GoogleFonts.beVietnamPro(
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Kategori
                  Text(
                    'Kategori',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Category chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _CategoryChip(
                    icon: Icons.all_inclusive,
                    label: 'Semua',
                    isActive: _selectedCategory == null,
                    onTap: () => _filterByCategory(null),
                  ),
                  ..._categories.map(
                    (cat) => _CategoryChip(
                      icon: _getCategoryIcon(cat.slug),
                      label: cat.name,
                      isActive: _selectedCategory == cat.slug,
                      onTap: () => _filterByCategory(cat.slug),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rekomendasi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Pilihan terbaik untuk petualanganmu',
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          // 🎯 Logika Pintar: Intip item pertama di list rekomendasi untuk tahu minat user
                          String? currentInterest;

                          if (_recommendations.isNotEmpty) {
                            final firstItem = _recommendations.first;
                            if (firstItem is Culinary) {
                              currentInterest = 'kuliner';
                            } else {
                              currentInterest =
                                  'wisata'; // Fallback default jika tipenya destinasi wisata
                            }
                          }

                          // Oper kata minat tersebut ke halaman search
                          Navigator.pushNamed(
                            context,
                            '/search',
                            arguments: currentInterest,
                          );
                        },
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
                ],
              ),
            ),
          ),
          // Recommendation cards
          SliverToBoxAdapter(
            child: _isLoading
                ? const SizedBox(
                    height: 280,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SizedBox(
                    height: 280,
                    child: _recommendations.isEmpty
                        ? const Center(
                            child: Text('Tidak ada rekomendasi untuk minatmu'),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _recommendations.length,
                            itemBuilder: (context, index) {
                              final item = _recommendations[index];

                              // 🍲 Jika item yang dikirim Laravel bertipe Culinary (Milik Ahmad)
                              if (item is Culinary) {
                                return _CulinaryHorizontalCard(
                                  image: item.image,
                                  name: item.name,
                                  location: item.location,
                                  rating: item.rating.toString(),
                                  slug: item.slug,
                                );
                              }
                              // 🏔️ Jika item yang dikirim Laravel bertipe Destination (Milik Abdul)
                              else if (item is Destination) {
                                return _DestinationCard(
                                  image: item.image,
                                  name: item.name,
                                  location: item.location,
                                  rating: item.rating.toString(),
                                  slug: item.slug,
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                  ),
          ),
          // Wisata Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                'Wisata',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: _destinations.isEmpty
                  ? const Center(child: Text('Tidak ada destinasi populer'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _destinations.length,
                      itemBuilder: (context, index) {
                        final dest = _destinations[index];
                        return _DestinationCard(
                          image: dest.image,
                          name: dest.name,
                          location: dest.location,
                          rating: dest.rating.toString(),
                          slug: dest.slug,
                        );
                      },
                    ),
            ),
          ),
          // Kuliner section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                'Kuliner',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= _culinaries.length) {
                return const SizedBox(height: 24);
              }
              final culinary = _culinaries[index];
              return _KulinerCard(
                image: culinary.image,
                name: culinary.name,
                since: '${culinary.categoryName ?? ''} • ${culinary.location}',
                rating: culinary.rating.toString(),
                reviews: '${culinary.totalReviews} ulasan',
                slug: culinary.slug,
                culinaryId: culinary.id,
                initialBookmarked: culinary.isBookmarked,
                onBookmarkChanged: () => _loadData(),
              );
            }, childCount: _culinaries.length + 1),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String slug) {
    switch (slug) {
      case 'wisata-alam':
        return Icons.landscape;
      case 'budaya':
        return Icons.castle_outlined;
      case 'kuliner':
        return Icons.restaurant_outlined;
      case 'belanja':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.place;
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.surfaceContainerHighest
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final String image, name, location, rating;
  final String? slug;
  const _DestinationCard({
    required this.image,
    required this.name,
    required this.location,
    required this.rating,
    this.slug,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (slug != null) {
          // 🛠️ 1. Simpan navigator ke variabel SEBELUM proses async (menghindari async gap warning)
          final navigator = Navigator.of(context);

          // 🛠️ 2. Tunggu proses pindah halaman sampai user menekan tombol 'back'
          await navigator.pushNamed('/destination', arguments: slug);

          // 🛠️ 3. Ambil state dari halaman induk (HomeScreenState) secara aman
          if (context.mounted) {
            final homeState = context.findAncestorStateOfType<State>();

            if (homeState != null && homeState.mounted) {
              // Panggil fungsi refresh di HomeScreen secara dinamis
              try {
                (homeState as dynamic)._loadData();
              } catch (_) {
                try {
                  (homeState as dynamic)._fetchData();
                } catch (_) {}
              }
            }
          }
        }
      },
      child: Container(
        width: 288,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    image,
                    height: 192,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 192,
                      color: AppColors.surfaceContainer,
                      child: const Icon(
                        Icons.image,
                        size: 48,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        location,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 12,
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
      ),
    );
  }
}

class _CulinaryHorizontalCard extends StatelessWidget {
  final String image, name, location, rating;
  final String? slug;
  const _CulinaryHorizontalCard({
    required this.image,
    required this.name,
    required this.location,
    required this.rating,
    this.slug,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (slug != null) {
          Navigator.pushNamed(context, '/culinary', arguments: slug);
        }
      },
      child: Container(
        width: 288,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    image,
                    height: 192,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 192,
                      color: AppColors.surfaceContainer,
                      child: const Icon(
                        Icons.restaurant,
                        size: 48,
                        color: AppColors.outline,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          rating,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        location,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 12,
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
      ),
    );
  }
}

class _KulinerCard extends StatefulWidget {
  final String image, name, since, rating, reviews;
  final String? slug;
  final int? culinaryId;
  final bool? initialBookmarked;
  final VoidCallback? onBookmarkChanged;

  const _KulinerCard({
    required this.image,
    required this.name,
    required this.since,
    required this.rating,
    required this.reviews,
    this.slug,
    this.culinaryId,
    this.initialBookmarked,
    this.onBookmarkChanged,
  });

  @override
  State<_KulinerCard> createState() => _KulinerCardState();
}

class _KulinerCardState extends State<_KulinerCard> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.initialBookmarked ?? false;
  }

  @override
  void didUpdateWidget(_KulinerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBookmarked != oldWidget.initialBookmarked) {
      setState(() {
        _isBookmarked = widget.initialBookmarked ?? false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (widget.culinaryId == null) return;

    final success = await ApiService().toggleBookmark(
      'culinary',
      widget.culinaryId!,
    );
    if (success && mounted) {
      setState(() => _isBookmarked = !_isBookmarked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked ? 'Ditambahkan ke bookmark' : 'Dihapus dari bookmark',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
      widget.onBookmarkChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.slug != null) {
          Navigator.pushNamed(context, '/culinary', arguments: widget.slug);
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.image,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 96,
                  height: 96,
                  color: AppColors.surfaceContainer,
                  child: const Icon(Icons.restaurant, color: AppColors.outline),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW UTAMA YANG MENAMPUNG TEKS DAN TOMBOL BOOKMARK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // Diubah ke start agar tombol bookmark tetap presisi di atas
                    children: [
                      // 1. BUNGKUS COLUMN TEKS DENGAN EXPANDED
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'Legendaris',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 2. BERIKAN MAXLINES & ELLIPSIS PADA NAMA KULINER
                            Text(
                              widget.name,
                              maxLines:
                                  1, // Batasi 1 baris agar tidak merusak baris rating di bawahnya
                              overflow: TextOverflow
                                  .ellipsis, // Otomatis jadi titik-titik (...) jika kepanjangan
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              widget.since,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // BERI JARAK AMAN ANTARA TEKS DAN TOMBOL
                      const SizedBox(width: 8),

                      // 3. TOMBOL BOOKMARK SEKARANG AMAN DI SISI KANAN
                      IconButton(
                        constraints:
                            const BoxConstraints(), // Mempersempit padding bawaan IconButton biar hemat space
                        padding: EdgeInsets
                            .zero, // Set ke nol agar tidak memakan ruang luar
                        icon: Icon(
                          _isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: AppColors.primary,
                        ),
                        onPressed: _toggleBookmark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        widget.rating,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '• ${widget.reviews}',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
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
      ),
    );
  }
}
