import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../models/destination.dart';
import '../models/culinary.dart';
import '../models/event.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<Destination> _destinations = [];
  List<Culinary> _culinaries = [];
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadInitialContent();
  }

  Future<void> _loadInitialContent() async {
    setState(() => _isLoading = true);
    try {
      final destinations = await ApiService().getDestinations(featured: true);
      final culinaries = await ApiService().getCulinaries(featured: true);
      final events = await ApiService().getEvents(upcoming: true);
      
      if (mounted) {
        setState(() {
          _destinations = destinations;
          _culinaries = culinaries;
          _events = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _loadInitialContent();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await ApiService().search(query);
      setState(() {
        _destinations = results['destinations'];
        _culinaries = results['culinaries'];
        _events = results['events'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasResults = _destinations.isNotEmpty || _culinaries.isNotEmpty || _events.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Cari destinasi, kuliner, event...',
            border: InputBorder.none,
            hintStyle: GoogleFonts.beVietnamPro(color: AppColors.outline),
          ),
          onChanged: (v) => _search(v),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !hasResults && _searchController.text.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: AppColors.outline),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada hasil',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : !hasResults && _searchController.text.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: AppColors.outline),
                          const SizedBox(height: 16),
                          Text(
                            'Cari destinasi, kuliner, atau event',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (_destinations.isNotEmpty) ...[
                      Text(
                        'Destinasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._destinations.map((d) => _SearchResultCard(
                            title: d.name,
                            subtitle: d.location,
                            image: d.image,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/destination',
                              arguments: d.slug,
                            ),
                          )),
                      const SizedBox(height: 24),
                    ],
                    if (_culinaries.isNotEmpty) ...[
                      Text(
                        'Kuliner',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._culinaries.map((c) => _SearchResultCard(
                            title: c.name,
                            subtitle: c.location,
                            image: c.image,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/culinary',
                              arguments: c.slug,
                            ),
                          )),
                      const SizedBox(height: 24),
                    ],
                    if (_events.isNotEmpty) ...[
                      Text(
                        'Event',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._events.map((e) => _SearchResultCard(
                            title: e.name,
                            subtitle: e.location,
                            image: e.image,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/event',
                              arguments: e.slug,
                            ),
                          )),
                    ],
                  ],
                ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final String title, subtitle, image;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            image,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 56,
              height: 56,
              color: AppColors.surfaceContainer,
              child: const Icon(Icons.image),
            ),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: GoogleFonts.beVietnamPro(fontSize: 12)),
        onTap: onTap,
      ),
    );
  }
}
