class Event {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? categoryName;
  final String location;
  final double? latitude;
  final double? longitude;
  final String image;
  final List<String> images;
  final String startDate;
  final String endDate;
  final String? startTime;
  final String? endTime;
  final String? organizer;
  final String? ticketPrice;
  final bool isFree;
  final bool isFeatured;
  final bool isBookmarked;

  Event({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.categoryName,
    required this.location,
    this.latitude,
    this.longitude,
    required this.image,
    this.images = const [],
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
    this.organizer,
    this.ticketPrice,
    required this.isFree,
    required this.isFeatured,
    this.isBookmarked = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'] ?? '',
      categoryName: json['category_name'],
      location: json['location'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      image: json['image'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      startTime: json['start_time'],
      endTime: json['end_time'],
      organizer: json['organizer'],
      ticketPrice: json['ticket_price'],
      isFree: json['is_free'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      isBookmarked: json['is_bookmarked'] ?? false,
    );
  }
}
