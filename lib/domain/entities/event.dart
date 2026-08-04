/// Entità evento.
class Event {
  const Event({
    required this.id,
    required this.externalId,
    required this.source,
    required this.name,
    this.artistName,
    this.artistSpotifyId,
    this.venueName,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    required this.eventDate,
    this.ticketUrl,
    this.priceMin,
    this.priceMax,
    this.imageUrl,
    this.description,
    this.status,
    this.createdAt,
  });

  final String id;
  final String externalId;
  final String source;
  final String name;
  final String? artistName;
  final String? artistSpotifyId;
  final String? venueName;
  final String? city;
  final String? country;
  final double? latitude;
  final double? longitude;
  final DateTime eventDate;
  final String? ticketUrl;
  final double? priceMin;
  final double? priceMax;
  final String? imageUrl;
  final String? description;
  final String? status;
  final DateTime? createdAt;
  Map<String, dynamic> toJson() => {
    'id': id,
    'externalId': externalId,
    'source': source,
    'name': name,
    'artistName': artistName,
    'artistSpotifyId': artistSpotifyId,
    'venueName': venueName,
    'city': city,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'eventDate': eventDate.toIso8601String(),
    'ticketUrl': ticketUrl,
    'priceMin': priceMin,
    'priceMax': priceMax,
    'imageUrl': imageUrl,
    'description': description,
    'status': status,
    'createdAt': createdAt?.toIso8601String(),
  };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'] as String,
    externalId: json['externalId'] as String,
    source: json['source'] as String,
    name: json['name'] as String,
    artistName: json['artistName'] as String?,
    artistSpotifyId: json['artistSpotifyId'] as String?,
    venueName: json['venueName'] as String?,
    city: json['city'] as String?,
    country: json['country'] as String?,
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
    eventDate: DateTime.parse(json['eventDate'] as String),
    ticketUrl: json['ticketUrl'] as String?,
    priceMin: (json['priceMin'] as num?)?.toDouble(),
    priceMax: (json['priceMax'] as num?)?.toDouble(),
    imageUrl: json['imageUrl'] as String?,
    description: json['description'] as String?,
    status: json['status'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
  );
}

class EventAttendee {
  const EventAttendee({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String eventId;
  final String status;
  final DateTime? createdAt;
}
