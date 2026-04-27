class Review {
  final int id;
  final int userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String? comment;
  final List<String> images;
  final String createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    this.images = const [],
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? 'Anonymous',
      userAvatar: json['user_avatar'],
      rating: json['rating'] ?? 5,
      comment: json['comment'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'images': images,
      'created_at': createdAt,
    };
  }
}
