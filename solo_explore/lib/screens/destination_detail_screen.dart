import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../models/destination.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String slug;
  const DestinationDetailScreen({super.key, required this.slug});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  Destination? _destination;
  bool _isLoading = true;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final destination = await ApiService().getDestinationDetail(widget.slug);
      if (mounted) {
        setState(() {
          _destination = destination;
          _isBookmarked = destination?.isBookmarked ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (_destination == null) return;
    final success = await ApiService().toggleBookmark('destination', _destination!.id);
    if (success && mounted) {
      setState(() => _isBookmarked = !_isBookmarked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'Ditambahkan ke bookmark' : 'Dihapus dari bookmark'),
          duration: const Duration(seconds: 1),
        ),
      );
      // Reload data to persist bookmark state
      _loadData();
    }
  }

  Future<void> _recordVisit() async {
    if (_destination == null) return;
    final success = await ApiService().recordVisitDestination(_destination!.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kunjungan berhasil dicatat! +50 poin'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _shareDestination() {
    if (_destination == null) return;
    
    final String shareText = '''
🗺️ ${_destination!.name}

📍 ${_destination!.location}
⭐ Rating: ${_destination!.rating}/5.0

${_destination!.description}

Jelajahi lebih banyak destinasi menarik di Solo Raya dengan aplikasi Solo Explore!

#SoloExplore #WisataSolo #ExploreSolo
''';

    Share.share(
      shareText,
      subject: 'Lihat ${_destination!.name} di Solo Explore',
    );
  }

  Future<void> _openDirections() async {
    if (_destination == null) return;
    
    final lat = _destination!.latitude;
    final lng = _destination!.longitude;
    final name = Uri.encodeComponent(_destination!.name);
    
    // Google Maps URL with directions
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$name');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showReviewDialog() {
    if (_destination == null) return;
    
    int rating = 5;
    final commentController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(
            'Beri Ulasan',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rating:', style: GoogleFonts.beVietnamPro()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setDialogState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Tulis ulasan Anda...',
                  border: const OutlineInputBorder(),
                  hintStyle: GoogleFonts.beVietnamPro(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: GoogleFonts.beVietnamPro()),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                if (comment.isEmpty) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Mohon tulis ulasan')),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                final success = await ApiService().addReviewDestination(
                  _destination!.id,
                  rating,
                  comment,
                );
                if (success) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Ulasan berhasil ditambahkan! +25 poin'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadData();
                }
              },
              child: Text('Kirim', style: GoogleFonts.beVietnamPro()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddToPlanDialog() async {
    if (_destination == null) return;

    try {
      final response = await ApiService().getTripPlans();
      if (!response['success'] || !mounted) return;

      final plans = response['data'] as List;
      if (plans.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Belum ada trip plan. Buat dulu di menu Planner')),
          );
        }
        return;
      }

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);

      await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            'Pilih Trip Plan',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: plans.length,
              itemBuilder: (dialogContext, index) {
                final plan = plans[index];
                return ListTile(
                  title: Text(
                    plan['title'] ?? plan['name'] ?? 'Trip Plan',
                    style: GoogleFonts.beVietnamPro(),
                  ),
                  subtitle: Text(
                    '${plan['start_date']} - ${plan['end_date']}',
                    style: GoogleFonts.beVietnamPro(fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(dialogContext);
                    final success = await ApiService().addItemToPlan(
                      plan['id'],
                      {
                        'plannable_type': 'destination',
                        'plannable_id': _destination!.id,
                        'day_number': 1,
                      },
                    );
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Destinasi berhasil ditambahkan ke trip plan'
                            : 'Gagal menambahkan ke trip plan'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: GoogleFonts.beVietnamPro()),
            ),
          ],
        ),
      );
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_destination == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Destinasi tidak ditemukan')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _destination!.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.surfaceContainer,
                  child: const Icon(Icons.image, size: 64),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_outline),
                onPressed: _toggleBookmark,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareDestination,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      _destination!.categoryName,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _destination!.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${_destination!.rating}',
                        style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        ' (${_destination!.totalReviews} ulasan)',
                        style: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(icon: Icons.location_on, text: _destination!.location),
                  if (_destination!.ticketPrice != null)
                    _InfoRow(icon: Icons.confirmation_number, text: _destination!.ticketPrice!),
                  if (_destination!.openingHours != null)
                    _InfoRow(icon: Icons.access_time, text: _destination!.openingHours!),
                  const SizedBox(height: 24),
                  Text(
                    'Deskripsi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _destination!.description,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () => _showReviewDialog(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            icon: const Icon(Icons.rate_review),
                            label: Text(
                              'Beri Ulasan',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => _recordVisit(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.onSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle),
                            label: Text(
                              'Sudah Kunjungi',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _openDirections,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      icon: const Icon(Icons.directions),
                      label: Text(
                        'Petunjuk Arah',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _showAddToPlanDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      icon: const Icon(Icons.add_to_photos),
                      label: Text(
                        'Tambah ke Trip Plan',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.beVietnamPro(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
