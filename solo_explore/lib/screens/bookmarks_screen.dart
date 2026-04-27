import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../models/bookmark.dart';
import '../models/destination.dart';
import '../models/culinary.dart';
import '../models/event.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;
  String _currentType = 'destination';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadBookmarks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _currentType = 'destination';
            break;
          case 1:
            _currentType = 'culinary';
            break;
          case 2:
            _currentType = 'event';
            break;
        }
      });
      _loadBookmarks();
    }
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    try {
      final bookmarksData = await ApiService().getBookmarks();
      final bookmarks = bookmarksData.map((data) => Bookmark.fromJson(data)).toList();
      
      // Filter by current type
      final filtered = bookmarks.where((b) {
        return b.type.toLowerCase().contains(_currentType);
      }).toList();
      
      if (mounted) {
        setState(() {
          _bookmarks = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bookmarks: $e')),
        );
      }
    }
  }

  Future<void> _removeBookmark(Bookmark bookmark) async {
    try {
      // Extract item ID from bookmark
      int itemId = 0;
      if (bookmark.item is Destination) {
        itemId = (bookmark.item as Destination).id;
      } else if (bookmark.item is Culinary) {
        itemId = (bookmark.item as Culinary).id;
      } else if (bookmark.item is Event) {
        itemId = (bookmark.item as Event).id;
      }
      
      await ApiService().toggleBookmark(_currentType, itemId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bookmark dihapus')),
        );
        _loadBookmarks();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          unselectedLabelStyle: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Destinasi'),
            Tab(text: 'Kuliner'),
            Tab(text: 'Event'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_outline,
                        size: 64,
                        color: AppColors.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada bookmark',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan ${_getTypeLabel()} favoritmu',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = _bookmarks[index];
                    return _BookmarkCard(
                      bookmark: bookmark,
                      onTap: () => _navigateToDetail(bookmark),
                      onRemove: () => _removeBookmark(bookmark),
                    );
                  },
                ),
    );
  }

  String _getTypeLabel() {
    switch (_currentType) {
      case 'destination':
        return 'destinasi';
      case 'culinary':
        return 'kuliner';
      case 'event':
        return 'event';
      default:
        return 'item';
    }
  }

  void _navigateToDetail(Bookmark bookmark) {
    String? slug;
    if (bookmark.item is Destination) {
      slug = (bookmark.item as Destination).slug;
      Navigator.pushNamed(context, '/destination', arguments: slug);
    } else if (bookmark.item is Culinary) {
      slug = (bookmark.item as Culinary).slug;
      Navigator.pushNamed(context, '/culinary', arguments: slug);
    } else if (bookmark.item is Event) {
      slug = (bookmark.item as Event).slug;
      Navigator.pushNamed(context, '/event', arguments: slug);
    }
  }
}

class _BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookmarkCard({
    required this.bookmark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final image = bookmark.itemImage;
    final name = bookmark.itemName;
    final location = bookmark.itemLocation;
    
    double rating = 0.0;
    if (bookmark.item is Destination) {
      rating = (bookmark.item as Destination).rating;
    } else if (bookmark.item is Culinary) {
      rating = (bookmark.item as Culinary).rating;
    } else if (bookmark.item is Event) {
      rating = 0.0; // Events don't have rating
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 96,
                  height: 96,
                  color: AppColors.surfaceContainer,
                  child: Icon(
                    _getIcon(),
                    size: 32,
                    color: AppColors.outline,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark, color: AppColors.primary),
                        onPressed: onRemove,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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

  IconData _getIcon() {
    if (bookmark.item is Destination) {
      return Icons.place;
    } else if (bookmark.item is Culinary) {
      return Icons.restaurant;
    } else if (bookmark.item is Event) {
      return Icons.event;
    }
    return Icons.bookmark;
  }
}
