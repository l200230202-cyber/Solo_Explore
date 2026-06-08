import 'culinary.dart'; // Mengimpor class Review yang sudah kita buat kemarin

class Destination {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String location;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String image;
  final List<String> images;
  final double rating;
  final int totalReviews;
  final String? ticketPrice;
  final String? openingHours;
  final bool? isOpen;
  final bool? isFeatured;
  final bool? isBookmarked;
  final String categoryName;
  final List<Review> reviews; // ✅ Tambahkan ini

  Destination({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.location,
    this.address,
    this.latitude,
    this.longitude,
    required this.image,
    this.images = const [],
    required this.rating,
    required this.totalReviews,
    this.ticketPrice,
    this.openingHours,
    this.isOpen,
    this.isFeatured,
    this.isBookmarked,
    required this.categoryName,
    this.reviews = const [], // ✅ Default ke list kosong
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      address: json['address'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      image: json['image'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString()) ?? 0.0
          : 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      ticketPrice: json['ticket_price'],
      openingHours: json['opening_hours'],
      isOpen: json['is_open'],
      isFeatured: json['is_featured'],
      isBookmarked: json['is_bookmarked'],
      categoryName: json['category_name'] ?? '',
      // ✅ Ambil data list ulasan wisata dari API Laravel
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => Review.fromJson(r)).toList()
          : [],
    );
  }
}
