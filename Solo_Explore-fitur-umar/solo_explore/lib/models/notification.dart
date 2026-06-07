class AppNotification {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  String get icon {
    switch (type) {
      case 'badge_earned':
        return '🏆';
      case 'level_up':
        return '⬆️';
      case 'reward_available':
        return '🎁';
      case 'event_reminder':
        return '📅';
      case 'points_earned':
        return '⭐';
      default:
        return '🔔';
    }
  }
}
