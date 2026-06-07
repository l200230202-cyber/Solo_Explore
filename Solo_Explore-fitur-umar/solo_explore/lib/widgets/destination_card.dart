import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class DestinationCard extends StatelessWidget {
  final String image; // URL lengkap atau path dari API
  final String name;
  final String location;
  final String rating;
  final String? distance;
  final VoidCallback? onTap;

  // Sesuaikan dengan alamat IP atau domain server Laravel kamu
  final String baseUrl = 'http://10.0.2.2:8000'; 

  const DestinationCard({
    super.key,
    required this.image,
    required this.name,
    required this.location,
    required this.rating,
    this.distance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Logika untuk menentukan URL gambar
    // Jika image sudah dimulai dengan http/https, gunakan apa adanya.
    // Jika tidak, tambahkan baseUrl + /storage/ agar mengakses file lokal Laravel.
    final String imageUrl = image.startsWith('http') 
        ? image 
        : '$baseUrl/storage/$image';

    return GestureDetector(
      onTap: onTap,
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
                    imageUrl,
                    height: 192,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading image: $error'); // Membantu debugging di konsol
                      return Container(
                        height: 192,
                        color: AppColors.surfaceContainer,
                        child: const Icon(Icons.broken_image, size: 48, color: AppColors.outline),
                      );
                    },
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 2),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}