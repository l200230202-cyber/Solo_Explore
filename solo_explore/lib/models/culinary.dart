class Culinary {
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
  final String? priceRange;
  final String? since;
  final String? categoryName;
  final bool? isHalal;
  final bool? isFeatured;
  final bool? isBookmarked;
  final List<Review> reviews; // ✅ Tambahkan ini

  Culinary({
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
    this.priceRange,
    this.since,
    this.categoryName,
    this.isHalal,
    this.isFeatured,
    this.isBookmarked,
    this.reviews = const [], // ✅ Default ke list kosong
  });

  factory Culinary.fromJson(Map<String, dynamic> json) {
    return Culinary(
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
      priceRange: json['price_range'],
      since: json['since'],
      categoryName: json['category_name'],
      isHalal: json['is_halal'],
      isFeatured: json['is_featured'],
      isBookmarked: json['is_bookmarked'],
      // ✅ Parsing list ulasan dari API Laravel (biasanya key-nya 'reviews')
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => Review.fromJson(r)).toList()
          : [],
    );
  }
}

// ✅ Tambahkan class Review penampung data ulasan jika belum ada
class Review {
  final int id;
  final int rating;
  final String comment;
  final String? userName;

  Review({
    required this.id,
    required this.rating,
    required this.comment,
    this.userName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? '',
      // Menyesuaikan key dari API Laravel, biasanya 'user' -> 'name' atau 'user_name'
      userName:
          json['user_name'] ??
          (json['user'] != null ? json['user']['name'] : 'User'),
    );
  }
}
