import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../models/culinary.dart';


class CulinaryDetailScreen extends StatefulWidget {
  final String slug;
  const CulinaryDetailScreen({super.key, required this.slug});

  @override
  State<CulinaryDetailScreen> createState() => _CulinaryDetailScreenState();
}

class _CulinaryDetailScreenState extends State<CulinaryDetailScreen> {
  Culinary? _culinary;
  bool _isLoading = true;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final culinary = await ApiService().getCulinaryDetail(widget.slug);
      if (mounted) {
        setState(() {
          _culinary = culinary;
          _isBookmarked = culinary?.isBookmarked ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (_culinary == null) return;

    // 1. ✅ Ambil status boolean asli dari Laravel (true = ter-bookmark, false = dihapus)
    final bool currentBookmarkStatus = await ApiService().toggleBookmark(
      'culinary',
      _culinary!.id,
    );

    // 2. ✅ Karena fungsi ApiService barumu mengembalikan status bookmark (bukan status success req),
    // kita hapus kondisi 'if (success)' lama, dan langsung update state jika widget masih mounted.
    if (mounted) {
      setState(() {
        _isBookmarked =
            currentBookmarkStatus; // 😉 Langsung pakai data asli dari database
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked ? 'Ditambahkan ke bookmark' : 'Dihapus dari bookmark',
          ),
          duration: const Duration(seconds: 1),
        ),
      );

      // Mengambil data ulang (jika memang diperlukan untuk refresh info detail)
      _loadData();
    }
  }

  Future<void> _recordVisit() async {
    if (_culinary == null) return;

    final success = await ApiService().recordVisitCulinary(_culinary!.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kunjungan berhasil dicatat! +30 poin'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Kamu pernah mencatat kunjungan di tempat ini',
            style: TextStyle(fontFamily: 'BeVietnamPro'),
          ),
          backgroundColor: Colors.orange, // Warna oranye untuk peringatan
          behavior: SnackBarBehavior.floating, // Efek melayang biar kekinian
        ),
      );
      // ===============================================================
    }
  }

  void _shareCulinary() {
    if (_culinary == null) return;

    final String shareText =
        '''
🍽️ ${_culinary!.name}

📍 ${_culinary!.location}
⭐ Rating: ${_culinary!.rating}/5.0
${_culinary!.categoryName ?? ''}

${_culinary!.description.isNotEmpty ? _culinary!.description : 'Kuliner yang wajib dicoba!'}

Temukan lebih banyak kuliner lezat di Solo Raya dengan aplikasi Solo Explore!

#SoloExplore #KulinerSolo #MakanEnak
''';

    Share.share(shareText, subject: 'Coba ${_culinary!.name} di Solo Explore');
  }

  Future<void> _openDirections() async {
    if (_culinary == null) return;

    final lat = _culinary!.latitude;
    final lng = _culinary!.longitude;
    final name = Uri.encodeComponent(_culinary!.name);

    // Jika data koordinat dari API Laravel ternyata kosong, gunakan nama lokasi sebagai fallback pencarian
    if (lat == null || lng == null) {
      final fallbackUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$name',
      );
      try {
        if (await canLaunchUrl(fallbackUrl)) {
          await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch URL';
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
          );
        }
      }
      return;
    }

    // Skema URL Google Maps berdasarkan sistem operasi (Android/iOS)
    // Menggunakan parameter 'q' agar maps memunculkan pin merah di koordinat tersebut dengan nama kulinernya
    final String googleMapsUrl = 'geo:$lat,$lng?q=$lat,$lng($name)';
    final String appleMapsUrl = 'https://maps.apple.com/?q=$name&ll=$lat,$lng';

    final Uri url = Uri.parse(googleMapsUrl);
    final Uri iosUrl = Uri.parse(appleMapsUrl);

    try {
      if (await canLaunchUrl(url)) {
        // Untuk Android (membuka aplikasi Google Maps langsung)
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(iosUrl)) {
        // Untuk iOS (membuka Apple Maps / Google Maps iOS)
        await launchUrl(iosUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback terakhir: Buka Google Maps lewat browser web biasa
        final webUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        );
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showReviewDialog() {
    if (_culinary == null) return;

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
                final success = await ApiService().addReviewCulinary(
                  _culinary!.id,
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
    if (_culinary == null) return;

    try {
      final response = await ApiService().getTripPlans();
      if (!response['success'] || !mounted) return;

      // ✅ PERBAIKAN 1: Cast sebagai List<dynamic> agar elemen di dalamnya bisa dibaca sebagai Map
      final plans = response['data'] as List<dynamic>;
      if (plans.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Belum ada trip plan. Buat dulu di menu Planner'),
            ),
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
                    final success = await ApiService()
                        .addItemToPlan(plan['id'], {
                          'plannable_type': 'culinary',
                          'plannable_id': _culinary!.id,
                          'day_number': 1,
                        });
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Kuliner berhasil ditambahkan ke trip plan'
                              : 'Gagal menambahkan ke trip plan',
                        ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _openGoogleMapsReviews() async {
    if (_culinary == null) return;

    // Melakukan pencarian di Google Maps berdasarkan nama kuliner + lokasi Solo
    final query = Uri.encodeComponent(
      '${_culinary!.name} ${_culinary!.location} Solo',
    );
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_culinary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Kuliner tidak ditemukan')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            // 1. ✅ Menggunakan dengan .withValues(alpha: 0.3) agar bebas warning
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                foregroundColor: Colors.white,
                child: const BackButton(),
              ),
            ),
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _culinary!.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.surfaceContainer,
                  child: const Icon(Icons.restaurant, size: 64),
                ),
              ),
            ),
            actions: [
              // 2. ✅ Perbaikan tombol Bookmark
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  child: IconButton(
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: _isBookmarked ? AppColors.primary : Colors.white,
                    ),
                    onPressed: _toggleBookmark,
                  ),
                ),
              ),
              // 3. ✅ Perbaikan tombol Share
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: _shareCulinary,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_culinary!.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _culinary!.categoryName!,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    _culinary!.name,
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
                        '${_culinary!.rating}',
                        style: GoogleFonts.beVietnamPro(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        ' (${_culinary!.totalReviews} ulasan)',
                        style: GoogleFonts.beVietnamPro(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),

                      const Spacer(), // Dorong tulisan "Lihat di Maps" ke ujung kanan
                      // ✅ Berhasil disamakan dengan Destinasi
                      InkWell(
                        onTap: _openGoogleMapsReviews,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            'Lihat di Maps ↗',
                            style: GoogleFonts.beVietnamPro(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(icon: Icons.location_on, text: _culinary!.location),
                  if (_culinary!.priceRange != null)
                    _InfoRow(
                      icon: Icons.payments,
                      text: _culinary!.priceRange!,
                    ),
                  if (_culinary!.since != null)
                    _InfoRow(icon: Icons.history, text: _culinary!.since!),
                  if (_culinary!.isHalal == true)
                    _InfoRow(icon: Icons.verified, text: 'Halal'),
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
                    _culinary!.description,
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
                  const SizedBox(height: 32),
                  Text(
                    'Ulasan Pengunjung',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_culinary!.reviews.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Belum ada ulasan. Jadilah yang pertama memberikan ulasan!',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _culinary!.reviews.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final review = _culinary!.reviews[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  review.userName ?? 'User',
                                  style: GoogleFonts.beVietnamPro(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < review.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              review.comment,
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        );
                      },
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
            child: Text(text, style: GoogleFonts.beVietnamPro(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
