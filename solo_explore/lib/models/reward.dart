class Reward {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? image;
  final int requiredPoints;
  final String type;
  final String? value;
  final String? validUntil;
  final bool isActive;
  final bool isClaimed;
  final String? claimedAt;
  final String? code;
  final String? status;

  Reward({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.image,
    required this.requiredPoints,
    required this.type,
    this.value,
    this.validUntil,
    this.isActive = true,
    this.isClaimed = false,
    this.claimedAt,
    this.code,
    this.status,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'] ?? '',
      image: json['image'],
      requiredPoints: json['required_points'] ?? 0,
      type: json['type'] ?? '',
      value: json['value'],
      validUntil: json['valid_until'],
      isActive: json['is_active'] ?? true,
      isClaimed: json['is_claimed'] ?? false,
      claimedAt: json['claimed_at'],
      code: json['code'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'image': image,
      'required_points': requiredPoints,
      'type': type,
      'value': value,
      'valid_until': validUntil,
      'is_active': isActive,
      'is_claimed': isClaimed,
      'claimed_at': claimedAt,
      'code': code,
      'status': status,
    };
  }
}
