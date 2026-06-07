import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../models/event.dart';

class EventDetailScreen extends StatefulWidget {
  final String slug;
  const EventDetailScreen({super.key, required this.slug});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? _event;
  bool _isLoading = true;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final event = await ApiService().getEventDetail(widget.slug);
      if (mounted) {
        setState(() {
          _event = event;
          _isBookmarked = event?.isBookmarked ?? false;
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
    if (_event == null) return;
    final success = await ApiService().toggleBookmark('event', _event!.id);
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

  void _shareEvent() {
    if (_event == null) return;
    
    final String shareText = '''
🎉 ${_event!.name}

📅 ${_event!.startDate}${_event!.endDate.isNotEmpty ? ' - ${_event!.endDate}' : ''}
📍 ${_event!.location}
${_event!.isFree ? '🎫 Gratis' : '🎫 ${_event!.ticketPrice ?? 'Berbayar'}'}

${_event!.description.isNotEmpty ? _event!.description : 'Event menarik yang wajib dikunjungi!'}

Jangan lewatkan event seru di Solo Raya! Download aplikasi Solo Explore sekarang!

#SoloExplore #EventSolo #JelajahSolo
''';

    Share.share(
      shareText,
      subject: 'Ikuti ${_event!.name} di Solo Explore',
    );
  }

  Future<void> _openDirections() async {
    if (_event == null) return;
    
    final lat = _event!.latitude;
    final lng = _event!.longitude;
    final name = Uri.encodeComponent(_event!.name);
    
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

  Future<void> _showAddToPlanDialog() async {
    if (_event == null) return;

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

      // Simpan messenger dan navigator dari State context sebelum masuk dialog
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

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
                    navigator.pop(); // tutup dialog pertama

                    final totalDays = DateTime.parse(plan['end_date'])
                        .difference(DateTime.parse(plan['start_date']))
                        .inDays + 1;

                    final dayNumber = await showDialog<int>(
                      context: navigator.context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          'Pilih Hari',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        ),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: totalDays,
                            itemBuilder: (ctx, i) => ListTile(
                              title: Text('Hari ${i + 1}'),
                              onTap: () => Navigator.pop(ctx, i + 1),
                            ),
                          ),
                        ),
                      ),
                    );

                    if (dayNumber == null) return;

                    final success = await ApiService().addItemToPlan(
                      plan['id'],
                      {
                        'plannable_type': 'event',
                        'plannable_id': _event!.id,
                        'day_number': dayNumber,
                        'time': _event!.startTime ?? '09:00',
                        'notes': 'Event: ${_event!.name}',
                      },
                    );

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Event berhasil ditambahkan ke trip plan'
                            : 'Gagal menambahkan event ke trip plan'),
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

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('d MMMM yyyy', 'id_ID').format(dt);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Event tidak ditemukan')),
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
                _event!.image,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.surfaceContainer,
                  child: const Icon(Icons.event, size: 64),
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
                onPressed: _shareEvent,
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
                      _event!.categoryName ?? '',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _event!.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    text: '${_formatDate(_event!.startDate)} - ${_formatDate(_event!.endDate)}',
                  ),
                  if (_event!.startTime != null)
                    _InfoRow(
                      icon: Icons.access_time,
                      text: '${_event!.startTime} - ${_event!.endTime}',
                    ),
                  _InfoRow(icon: Icons.location_on, text: _event!.location),
                  if (_event!.organizer != null)
                    _InfoRow(icon: Icons.business, text: _event!.organizer!),
                  if (_event!.ticketPrice != null)
                    _InfoRow(
                      icon: Icons.confirmation_number,
                      text: _event!.isFree ? 'Gratis' : _event!.ticketPrice!,
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Tentang Event',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _event!.description,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
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
