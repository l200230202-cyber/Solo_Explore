import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // 🟢 WAJIB: Untuk memformat nama bulan secara otomatis
import '../core/theme.dart';
import '../services/api_service.dart';
import '../models/event.dart';
import '../widgets/notification_badge.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  late DateTime _currentMonth; // 🟢 Melacak bulan yang sedang dibuka
  late int _selectedDay;       // 🟢 Hari aktif pilihan user
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 🟢 Set otomatis ke tanggal hari ini secara real-time
    final kini = DateTime.now();
    _currentMonth = DateTime(kini.year, kini.month);
    _selectedDay = kini.day;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await ApiService().getEvents(upcoming: true);
      if (mounted) {
        setState(() {
          _events = events;
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

  // 🟢 Fungsi pembentuk grid kalender otomatis berdasarkan rumus DateTime bawaan
  List<int?> _generateCalendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    
    // Mencari hari apa tanggal 1 dimulai (0 = Minggu, 1 = Senin, dst.)
    int weekdayOffset = firstDayOfMonth.weekday % 7;
    
    final List<int?> days = List.generate(weekdayOffset, (index) => null);
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      days.add(i);
    }
    return days;
  }

  // 🟢 Mengecek apakah tanggal tertentu di kalender memiliki event dari database
  bool _hasEventOnDay(int day) {
    for (var event in _events) {
      try {
        final parsedDate = DateTime.parse(event.startDate);
        if (parsedDate.year == _currentMonth.year &&
            parsedDate.month == _currentMonth.month &&
            parsedDate.day == day) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 Memasukkan daftar tanggal dinamis hasil generate rumus
    final calendarDays = _generateCalendarDays(_currentMonth);
    
    // Format nama bulan Indonesia (Contoh: "Juni 2026")
    final String monthTitle = DateFormat('MMMM yyyy', 'id_ID').format(_currentMonth);

    // Cari tahu total event yang jatuh di tanggal yang sedang diklik user
    final filteredEvents = _events.where((event) {
      try {
        final parsedDate = DateTime.parse(event.startDate);
        return parsedDate.year == _currentMonth.year &&
               parsedDate.month == _currentMonth.month &&
               parsedDate.day == _selectedDay;
      } catch (_) {
        return false;
      }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFFF5FAF0).withValues(alpha: 0.9),
            elevation: 0,
            title: Text(
              'SoloExplore',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            leading: const Icon(Icons.menu, color: AppColors.primary),
            actions: const [NotificationBadge()],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kalender Event',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Temukan festival budaya terdekat di wilayah Solo Raya.',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // BOX KALENDER PINTAR
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              monthTitle, // 🟢 Mengikuti waktu dinamis
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                                  onPressed: () {
                                    setState(() {
                                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                                      _selectedDay = 1; // reset hari ke awal bulan baru
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                                  onPressed: () {
                                    setState(() {
                                      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                                      _selectedDay = 1;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['M', 'S', 'S', 'R', 'K', 'J', 'S']
                              .map((d) => SizedBox(
                                    width: 36,
                                    child: Text(
                                      d,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.beVietnamPro(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.outline.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        
                        // GRID GENERATOR OTOMATIS
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 1,
                          ),
                          itemCount: calendarDays.length,
                          itemBuilder: (context, index) {
                            final day = calendarDays[index];
                            if (day == null) return const SizedBox();
                            
                            final isSelected = day == _selectedDay;
                            final hasEvent = _hasEventOnDay(day); // 🟢 Deteksi event otomatis
                            
                            return GestureDetector(
                              onTap: () => setState(() => _selectedDay = day),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$day',
                                        style: GoogleFonts.beVietnamPro(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected ? Colors.white : AppColors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (hasEvent && !isSelected)
                                    Container(
                                      width: 6, height: 6,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: const BoxDecoration(
                                        color: AppColors.secondary, // Penanda dot dot event
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // JUDUL DAFTAR EVENT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Event Mendatang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
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
                  
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_events.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Tidak ada data event saat ini',
                          style: GoogleFonts.beVietnamPro(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        // 🟢 TAMPILKAN DAFTAR UTAMA SEMUA EVENT BESERTA LABEL EVENT TERDEKAT
                        ..._events.map((event) {
                          bool isSelectedDateEvent = filteredEvents.contains(event);
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Stack(
                              children: [
                                _EventCard(
                                  image: event.image,
                                  category: event.categoryName ?? '',
                                  name: event.name,
                                  date: '${event.startDate} - ${event.endDate}',
                                  location: event.location,
                                  slug: event.slug,
                                  eventId: event.id,
                                  initialBookmarked: event.isBookmarked,
                                  onBookmarkChanged: () => _loadEvents(),
                                ),
                                
                                // 🟢 LABEL PENANDA EVENT TERDEKAT: Menyala hijau jika tanggal card sama dengan yang dipilih user
                                if (isSelectedDateEvent)
                                  Positioned(
                                    bottom: 8,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade600,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.flash_on, size: 12, color: Colors.white),
                                          const SizedBox(width: 4),
                                          Text(
                                            'PILIHAN HARI INI',
                                            style: GoogleFonts.beVietnamPro(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatefulWidget {
  final String image, category, name, date, location;
  final String? slug;
  final int? eventId;
  final bool? initialBookmarked;
  final VoidCallback? onBookmarkChanged; 
  
  const _EventCard({
    required this.image,
    required this.category,
    required this.name,
    required this.date,
    required this.location,
    this.slug,
    this.eventId,
    this.initialBookmarked,
    this.onBookmarkChanged,  
  });

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.initialBookmarked ?? false;
  }

  @override
  void didUpdateWidget(_EventCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBookmarked != oldWidget.initialBookmarked) {
      setState(() {
        _isBookmarked = widget.initialBookmarked ?? false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (widget.eventId == null) return;
    
    final success = await ApiService().toggleBookmark('event', widget.eventId!);
    if (success && mounted) {
      setState(() => _isBookmarked = !_isBookmarked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isBookmarked ? 'Ditambahkan ke bookmark' : 'Dihapus dari bookmark'),
            duration: const Duration(seconds: 1),
          ),
        );
        widget.onBookmarkChanged?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.slug != null) {
          // 🟢 Memperbaiki rute agar pas diklik mengarah ke detail screen yang benar
          Navigator.pushNamed(context, '/destination-detail', arguments: widget.slug);
        }
      },
      child: Container(
        height: 144,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                widget.image,
                width: 120,
                height: 144,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 120,
                  color: AppColors.surfaceContainer,
                  child: const Icon(Icons.image, color: AppColors.outline),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            widget.category.toUpperCase(),
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                            color: _isBookmarked ? AppColors.primary : AppColors.outline,
                            size: 20,
                          ),
                          onPressed: _toggleBookmark,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    Text(
                      widget.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.date,
                            style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.location,
                            style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}