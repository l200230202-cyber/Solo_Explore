class User {
  final int id;
  final String name;
  final String email;
  final String? role; // <--- 1. TAMBAHKAN INI
  final String? phone;
  final String? avatar;
  final String? bio;
  final int level;
  final String levelTitle;
  final int points;
  final int totalDestinations;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role, // <--- 2. MASUKKAN KE CONSTRUCTOR
    this.phone,
    this.avatar,
    this.bio,
    required this.level,
    required this.levelTitle,
    required this.points,
    required this.totalDestinations,
    required this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'], // <--- 3. AMBIL DARI JSON LARAVEL
      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],
      level: json['level'] ?? 1,
      levelTitle: json['level_title'] ?? 'Beginner Explorer',
      points: json['points'] ?? 0,
      totalDestinations: json['total_destinations'] ?? 0,
      isVerified: json['is_verified'] is int 
          ? json['is_verified'] == 1 
          : (json['is_verified'] ?? false),
    );
  }
}
