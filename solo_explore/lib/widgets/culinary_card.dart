import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class CulinaryCard extends StatefulWidget {
  final String image;
  final String name;
  final String category;
  final String location;
  final String rating;
  final String reviews;
  final bool isLegendary;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const CulinaryCard({
    super.key,
    required this.image,
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.reviews,
    this.isLegendary = false,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmarkTap,
  });

  @override
  State<CulinaryCard> createState() => _CulinaryCardState();
}

class _CulinaryCardState extends State<CulinaryCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                widget.image,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 96,
                  height: 96,
                  color: AppColors.surfaceContainer,
                  child: const Icon(Icons.restaurant, size: 32, color: AppColors.outline),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.isLegendary)
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${widget.category} • ${widget.location}',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          widget.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                          color: AppColors.primary,
                        ),
                        onPressed: widget.onBookmarkTap,
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
