import 'destination.dart';
import 'culinary.dart';
import 'event.dart';

class Bookmark {
  final int id;
  final String type; // destination, culinary, event
  final dynamic item; // Destination, Culinary, or Event
  final String createdAt;

  Bookmark({
    required this.id,
    required this.type,
    required this.item,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    dynamic item;
    final type = json['bookmarkable_type'] ?? json['type'] ?? '';
    
    if (type.contains('Destination') || type == 'destination') {
      item = json['destination'] != null 
          ? Destination.fromJson(json['destination'])
          : null;
    } else if (type.contains('Culinary') || type == 'culinary') {
      item = json['culinary'] != null 
          ? Culinary.fromJson(json['culinary'])
          : null;
    } else if (type.contains('Event') || type == 'event') {
      item = json['event'] != null 
          ? Event.fromJson(json['event'])
          : null;
    }

    return Bookmark(
      id: json['id'],
      type: type,
      item: item,
      createdAt: json['created_at'] ?? '',
    );
  }

  String get itemName {
    if (item is Destination) return (item as Destination).name;
    if (item is Culinary) return (item as Culinary).name;
    if (item is Event) return (item as Event).name;
    return 'Unknown';
  }

  String get itemImage {
    if (item is Destination) return (item as Destination).image;
    if (item is Culinary) return (item as Culinary).image;
    if (item is Event) return (item as Event).image;
    return '';
  }

  String get itemLocation {
    if (item is Destination) return (item as Destination).location;
    if (item is Culinary) return (item as Culinary).location;
    if (item is Event) return (item as Event).location;
    return '';
  }
}
