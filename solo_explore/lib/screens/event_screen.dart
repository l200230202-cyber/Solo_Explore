import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  int _selectedDay = 12;
  final List<int> _daysWithEvents = [6, 13, 24];
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
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
            actions: const [
              NotificationBadge(),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Calendar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover cultural festivities in Solo Raya.',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Calendar
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
                              'September 2024',
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
                                    // Navigate to previous month
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Navigasi bulan sebelumnya')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                                  onPressed: () {
                                    // Navigate to next month
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Navigasi bulan berikutnya')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Day headers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
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
                        // Calendar grid
                        _buildCalendarGrid(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Events',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/search'),
                        child: Text(
                          'View All',
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
                          'Tidak ada event',
                          style: GoogleFonts.beVietnamPro(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._events.map((event) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _EventCard(
                            image: event.image,
                            category: event.categoryName ?? '',
                            name: event.name,
                            date: '${event.startDate} - ${event.endDate}',
                            location: event.location,
                            slug: event.slug,
                            eventId: event.id,
                            initialBookmarked: event.isBookmarked,
                            onBookmarkChanged: () => _loadEvents(),  // ✅ ADDED: Reload on bookmark change
                          ),
                        )),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Sep 2024 starts on Sunday
    final List<int?> days = [
      null, null, null, null, 1, 2, 3,
      4, 5, 6, 7, 8, 9, 10,
      11, 12, 13, 14, 15, 16, 17,
      18, 19, 20, 21, 22, 23, 24,
      25, 26, 27, 28, 29, 30, null,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        if (day == null) return const SizedBox();
        final isSelected = day == _selectedDay;
        final hasEvent = _daysWithEvents.contains(day);
        return GestureDetector(
          onTap: () => setState(() => _selectedDay = day),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
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
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EventCard extends StatefulWidget {
  final String image, category, name, date, location;
  final String? slug;
  final int? eventId;
  final bool? initialBookmarked;
  final VoidCallback? onBookmarkChanged;  // ✅ ADDED
  
  const _EventCard({
    required this.image,
    required this.category,
    required this.name,
    required this.date,
    required this.location,
    this.slug,
    this.eventId,
    this.initialBookmarked,
    this.onBookmarkChanged,  // ✅ ADDED
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
        // ✅ ADDED: Call callback to reload parent data
        widget.onBookmarkChanged?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.slug != null) {
          Navigator.pushNamed(context, '/event', arguments: widget.slug);
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        widget.date,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        widget.location,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
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
