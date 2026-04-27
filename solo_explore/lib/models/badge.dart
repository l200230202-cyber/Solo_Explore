class Badge {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final String? requirement;
  final int requiredPoints;
  final bool isEarned;
  final String? earnedAt;

  Badge({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    this.requirement,
    required this.requiredPoints,
    this.isEarned = false,
    this.earnedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      requirement: json['requirement'],
      requiredPoints: json['required_points'] ?? 0,
      isEarned: json['is_earned'] ?? false,
      earnedAt: json['earned_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'requirement': requirement,
      'required_points': requiredPoints,
      'is_earned': isEarned,
      'earned_at': earnedAt,
    };
  }
}
