class TripPlan {
  final int id;
  final String title;
  final String? description;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String status;
  final int itemsCount;
  final String createdAt;

  TripPlan({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.status,
    this.itemsCount = 0,
    required this.createdAt,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      totalDays: json['total_days'] ?? 1,
      status: json['status'] ?? 'draft',
      itemsCount: json['items_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate,
      'end_date': endDate,
      'total_days': totalDays,
      'status': status,
      'items_count': itemsCount,
      'created_at': createdAt,
    };
  }
}
