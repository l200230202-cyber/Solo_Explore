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
  final List<Review> reviews;

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
    this.reviews = const [],
  });

  factory Culinary.fromJson(Map<String, dynamic> json) {
    return Culinary(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',

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
      priceRange: json['price_range'] ?? '-',
      since: json['since'] ?? '-',
      categoryName: json['category_name'] ?? 'Kuliner',

      isHalal: json['is_halal'] is bool
          ? json['is_halal']
          : (json['is_halal'] == 1 || json['is_halal'] == '1'),

      isFeatured: json['is_featured'] is bool
          ? json['is_featured']
          : (json['is_featured'] == 1 || json['is_featured'] == '1'),

      isBookmarked: json['is_bookmarked'] is bool
          ? json['is_bookmarked']
          : (json['is_bookmarked'] == 1 || json['is_bookmarked'] == '1'),

      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((r) => Review.fromJson(r)).toList()
          : [],
    );
  }
}

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
      id: json['id'] ?? 0,
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? '',
      userName:
          json['user_name'] ??
          (json['user'] != null ? json['user']['name'] : 'User'),
    );
  }
}
