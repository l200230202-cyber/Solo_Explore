import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final bool showRatingText;
  final String? reviewCount;

  const RatingStars({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 16,
    this.showRatingText = true,
    this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(starCount, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, color: Colors.amber, size: size);
          } else if (index < rating) {
            return Icon(Icons.star_half, color: Colors.amber, size: size);
          } else {
            return Icon(Icons.star_outline, color: AppColors.outline, size: size);
          }
        }),
        if (showRatingText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.beVietnamPro(
              fontSize: size * 0.75,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ],
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: GoogleFonts.beVietnamPro(
              fontSize: size * 0.7,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
