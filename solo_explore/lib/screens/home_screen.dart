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
  bool _isLoading = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categories = await ApiService().getCategories();
      final destinations = await ApiService().getDestinations();
      final culinaries = await ApiService().getCulinaries();
      
      if (mounted) {
        setState(() {
          _categories = categories;
          _destinations = destinations;
          _culinaries = culinaries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _filterByCategory(String? categorySlug) async {
    setState(() {
      _selectedCategory = categorySlug;
      _isLoading = true;
    });
    
    try {
      if (categorySlug == null) {
        // Semua - load semua destinations dan culinaries
        final destinations = await ApiService().getDestinations();
        final culinaries = await ApiService().getCulinaries();
        if (mounted) {
          setState(() {
            _destinations = destinations;
            _culinaries = culinaries;
            _isLoading = false;
          });
        }
      } else if (categorySlug == 'kuliner') {
        // Kuliner - section rekomendasi tampil kuliner, section bawah juga kuliner
        final culinaries = await ApiService().getCulinaries();
        if (mounted) {
          setState(() {
            _destinations = [];
            _culinaries = culinaries;
            _isLoading = false;
          });
        }
      } else {
        // Kategori lain (wisata-alam, budaya, dll) - filter destinations,
        // section kuliner legendaris tetap tampil semua kuliner
        final destinations = await ApiService().getDestinations(category: categorySlug);
        final culinaries = await ApiService().getCulinaries();
        if (mounted) {
          setState(() {
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
            actions: const [
              NotificationBadge(),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
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
                            style: GoogleFonts.beVietnamPro(color: AppColors.outline),
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
                  ..._categories.map((cat) => _CategoryChip(
                    icon: _getCategoryIcon(cat.slug),
                    label: cat.name,
                    isActive: _selectedCategory == cat.slug,
                    onTap: () => _filterByCategory(cat.slug),
                  )),
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
                    child: _selectedCategory == 'kuliner'
                        ? (_culinaries.isEmpty
                            ? const Center(child: Text('Tidak ada kuliner'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                itemCount: _culinaries.length,
                                itemBuilder: (context, index) {
                                  final culinary = _culinaries[index];
                                  return _CulinaryHorizontalCard(
                                    image: culinary.image,
                                    name: culinary.name,
                                    location: culinary.location,
                                    rating: culinary.rating.toString(),
                                    slug: culinary.slug,
                                  );
                                },
                              ))
                        : (_destinations.isEmpty
                            ? const Center(child: Text('Tidak ada destinasi'))
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
                              )),
                  ),
          ),
          // Kuliner section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text(
                'Kuliner Legendaris',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= _culinaries.length) return const SizedBox(height: 24);
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
              },
              childCount: _culinaries.length + 1,
            ),
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
        color: isActive ? AppColors.surfaceContainerHighest : AppColors.surfaceContainerLow,
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
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
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
      onTap: () {
        if (slug != null) {
          Navigator.pushNamed(context, '/destination', arguments: slug);
        }
      },
      child: Container(
        width: 288,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  image,
                  height: 192,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 192,
                    color: AppColors.surfaceContainer,
                    child: const Icon(Icons.image, size: 48, color: AppColors.outline),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
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
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  image,
                  height: 192,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 192,
                    color: AppColors.surfaceContainer,
                    child: const Icon(Icons.restaurant, size: 48, color: AppColors.outline),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
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
    
    final success = await ApiService().toggleBookmark('culinary', widget.culinaryId!);
    if (success && mounted) {
      setState(() => _isBookmarked = !_isBookmarked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'Ditambahkan ke bookmark' : 'Dihapus dari bookmark'),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                        Text(
                          widget.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          widget.since,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
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
