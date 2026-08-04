// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventModel {

 String get id;@JsonKey(name: 'external_id') String get externalId; String get source;// ticketmaster|songkick|bandsintown
 String get name;@JsonKey(name: 'artist_name') String? get artistName;@JsonKey(name: 'artist_spotify_id') String? get artistSpotifyId;@JsonKey(name: 'venue_name') String? get venueName; String? get city; String? get country; double? get latitude; double? get longitude;@JsonKey(name: 'event_date') DateTime get eventDate;@JsonKey(name: 'ticket_url') String? get ticketUrl;@JsonKey(name: 'price_min') double? get priceMin;@JsonKey(name: 'price_max') double? get priceMax;@JsonKey(name: 'image_url') String? get imageUrl; String? get description; String? get status;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventModelCopyWith<EventModel> get copyWith => _$EventModelCopyWithImpl<EventModel>(this as EventModel, _$identity);

  /// Serializes this EventModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.source, source) || other.source == source)&&(identical(other.name, name) || other.name == name)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&(identical(other.artistSpotifyId, artistSpotifyId) || other.artistSpotifyId == artistSpotifyId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.ticketUrl, ticketUrl) || other.ticketUrl == ticketUrl)&&(identical(other.priceMin, priceMin) || other.priceMin == priceMin)&&(identical(other.priceMax, priceMax) || other.priceMax == priceMax)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,externalId,source,name,artistName,artistSpotifyId,venueName,city,country,latitude,longitude,eventDate,ticketUrl,priceMin,priceMax,imageUrl,description,status,createdAt]);

@override
String toString() {
  return 'EventModel(id: $id, externalId: $externalId, source: $source, name: $name, artistName: $artistName, artistSpotifyId: $artistSpotifyId, venueName: $venueName, city: $city, country: $country, latitude: $latitude, longitude: $longitude, eventDate: $eventDate, ticketUrl: $ticketUrl, priceMin: $priceMin, priceMax: $priceMax, imageUrl: $imageUrl, description: $description, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EventModelCopyWith<$Res>  {
  factory $EventModelCopyWith(EventModel value, $Res Function(EventModel) _then) = _$EventModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'external_id') String externalId, String source, String name,@JsonKey(name: 'artist_name') String? artistName,@JsonKey(name: 'artist_spotify_id') String? artistSpotifyId,@JsonKey(name: 'venue_name') String? venueName, String? city, String? country, double? latitude, double? longitude,@JsonKey(name: 'event_date') DateTime eventDate,@JsonKey(name: 'ticket_url') String? ticketUrl,@JsonKey(name: 'price_min') double? priceMin,@JsonKey(name: 'price_max') double? priceMax,@JsonKey(name: 'image_url') String? imageUrl, String? description, String? status,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$EventModelCopyWithImpl<$Res>
    implements $EventModelCopyWith<$Res> {
  _$EventModelCopyWithImpl(this._self, this._then);

  final EventModel _self;
  final $Res Function(EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? externalId = null,Object? source = null,Object? name = null,Object? artistName = freezed,Object? artistSpotifyId = freezed,Object? venueName = freezed,Object? city = freezed,Object? country = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? eventDate = null,Object? ticketUrl = freezed,Object? priceMin = freezed,Object? priceMax = freezed,Object? imageUrl = freezed,Object? description = freezed,Object? status = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,externalId: null == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,artistName: freezed == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String?,artistSpotifyId: freezed == artistSpotifyId ? _self.artistSpotifyId : artistSpotifyId // ignore: cast_nullable_to_non_nullable
as String?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,ticketUrl: freezed == ticketUrl ? _self.ticketUrl : ticketUrl // ignore: cast_nullable_to_non_nullable
as String?,priceMin: freezed == priceMin ? _self.priceMin : priceMin // ignore: cast_nullable_to_non_nullable
as double?,priceMax: freezed == priceMax ? _self.priceMax : priceMax // ignore: cast_nullable_to_non_nullable
as double?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventModel].
extension EventModelPatterns on EventModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventModel value)  $default,){
final _that = this;
switch (_that) {
case _EventModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventModel value)?  $default,){
final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'external_id')  String externalId,  String source,  String name, @JsonKey(name: 'artist_name')  String? artistName, @JsonKey(name: 'artist_spotify_id')  String? artistSpotifyId, @JsonKey(name: 'venue_name')  String? venueName,  String? city,  String? country,  double? latitude,  double? longitude, @JsonKey(name: 'event_date')  DateTime eventDate, @JsonKey(name: 'ticket_url')  String? ticketUrl, @JsonKey(name: 'price_min')  double? priceMin, @JsonKey(name: 'price_max')  double? priceMax, @JsonKey(name: 'image_url')  String? imageUrl,  String? description,  String? status, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.externalId,_that.source,_that.name,_that.artistName,_that.artistSpotifyId,_that.venueName,_that.city,_that.country,_that.latitude,_that.longitude,_that.eventDate,_that.ticketUrl,_that.priceMin,_that.priceMax,_that.imageUrl,_that.description,_that.status,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'external_id')  String externalId,  String source,  String name, @JsonKey(name: 'artist_name')  String? artistName, @JsonKey(name: 'artist_spotify_id')  String? artistSpotifyId, @JsonKey(name: 'venue_name')  String? venueName,  String? city,  String? country,  double? latitude,  double? longitude, @JsonKey(name: 'event_date')  DateTime eventDate, @JsonKey(name: 'ticket_url')  String? ticketUrl, @JsonKey(name: 'price_min')  double? priceMin, @JsonKey(name: 'price_max')  double? priceMax, @JsonKey(name: 'image_url')  String? imageUrl,  String? description,  String? status, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _EventModel():
return $default(_that.id,_that.externalId,_that.source,_that.name,_that.artistName,_that.artistSpotifyId,_that.venueName,_that.city,_that.country,_that.latitude,_that.longitude,_that.eventDate,_that.ticketUrl,_that.priceMin,_that.priceMax,_that.imageUrl,_that.description,_that.status,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'external_id')  String externalId,  String source,  String name, @JsonKey(name: 'artist_name')  String? artistName, @JsonKey(name: 'artist_spotify_id')  String? artistSpotifyId, @JsonKey(name: 'venue_name')  String? venueName,  String? city,  String? country,  double? latitude,  double? longitude, @JsonKey(name: 'event_date')  DateTime eventDate, @JsonKey(name: 'ticket_url')  String? ticketUrl, @JsonKey(name: 'price_min')  double? priceMin, @JsonKey(name: 'price_max')  double? priceMax, @JsonKey(name: 'image_url')  String? imageUrl,  String? description,  String? status, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EventModel() when $default != null:
return $default(_that.id,_that.externalId,_that.source,_that.name,_that.artistName,_that.artistSpotifyId,_that.venueName,_that.city,_that.country,_that.latitude,_that.longitude,_that.eventDate,_that.ticketUrl,_that.priceMin,_that.priceMax,_that.imageUrl,_that.description,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventModel implements EventModel {
  const _EventModel({required this.id, @JsonKey(name: 'external_id') required this.externalId, required this.source, required this.name, @JsonKey(name: 'artist_name') this.artistName, @JsonKey(name: 'artist_spotify_id') this.artistSpotifyId, @JsonKey(name: 'venue_name') this.venueName, this.city, this.country, this.latitude, this.longitude, @JsonKey(name: 'event_date') required this.eventDate, @JsonKey(name: 'ticket_url') this.ticketUrl, @JsonKey(name: 'price_min') this.priceMin, @JsonKey(name: 'price_max') this.priceMax, @JsonKey(name: 'image_url') this.imageUrl, this.description, this.status, @JsonKey(name: 'created_at') this.createdAt});
  factory _EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'external_id') final  String externalId;
@override final  String source;
// ticketmaster|songkick|bandsintown
@override final  String name;
@override@JsonKey(name: 'artist_name') final  String? artistName;
@override@JsonKey(name: 'artist_spotify_id') final  String? artistSpotifyId;
@override@JsonKey(name: 'venue_name') final  String? venueName;
@override final  String? city;
@override final  String? country;
@override final  double? latitude;
@override final  double? longitude;
@override@JsonKey(name: 'event_date') final  DateTime eventDate;
@override@JsonKey(name: 'ticket_url') final  String? ticketUrl;
@override@JsonKey(name: 'price_min') final  double? priceMin;
@override@JsonKey(name: 'price_max') final  double? priceMax;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override final  String? description;
@override final  String? status;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventModelCopyWith<_EventModel> get copyWith => __$EventModelCopyWithImpl<_EventModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventModel&&(identical(other.id, id) || other.id == id)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.source, source) || other.source == source)&&(identical(other.name, name) || other.name == name)&&(identical(other.artistName, artistName) || other.artistName == artistName)&&(identical(other.artistSpotifyId, artistSpotifyId) || other.artistSpotifyId == artistSpotifyId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.city, city) || other.city == city)&&(identical(other.country, country) || other.country == country)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.eventDate, eventDate) || other.eventDate == eventDate)&&(identical(other.ticketUrl, ticketUrl) || other.ticketUrl == ticketUrl)&&(identical(other.priceMin, priceMin) || other.priceMin == priceMin)&&(identical(other.priceMax, priceMax) || other.priceMax == priceMax)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,externalId,source,name,artistName,artistSpotifyId,venueName,city,country,latitude,longitude,eventDate,ticketUrl,priceMin,priceMax,imageUrl,description,status,createdAt]);

@override
String toString() {
  return 'EventModel(id: $id, externalId: $externalId, source: $source, name: $name, artistName: $artistName, artistSpotifyId: $artistSpotifyId, venueName: $venueName, city: $city, country: $country, latitude: $latitude, longitude: $longitude, eventDate: $eventDate, ticketUrl: $ticketUrl, priceMin: $priceMin, priceMax: $priceMax, imageUrl: $imageUrl, description: $description, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EventModelCopyWith<$Res> implements $EventModelCopyWith<$Res> {
  factory _$EventModelCopyWith(_EventModel value, $Res Function(_EventModel) _then) = __$EventModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'external_id') String externalId, String source, String name,@JsonKey(name: 'artist_name') String? artistName,@JsonKey(name: 'artist_spotify_id') String? artistSpotifyId,@JsonKey(name: 'venue_name') String? venueName, String? city, String? country, double? latitude, double? longitude,@JsonKey(name: 'event_date') DateTime eventDate,@JsonKey(name: 'ticket_url') String? ticketUrl,@JsonKey(name: 'price_min') double? priceMin,@JsonKey(name: 'price_max') double? priceMax,@JsonKey(name: 'image_url') String? imageUrl, String? description, String? status,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$EventModelCopyWithImpl<$Res>
    implements _$EventModelCopyWith<$Res> {
  __$EventModelCopyWithImpl(this._self, this._then);

  final _EventModel _self;
  final $Res Function(_EventModel) _then;

/// Create a copy of EventModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? externalId = null,Object? source = null,Object? name = null,Object? artistName = freezed,Object? artistSpotifyId = freezed,Object? venueName = freezed,Object? city = freezed,Object? country = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? eventDate = null,Object? ticketUrl = freezed,Object? priceMin = freezed,Object? priceMax = freezed,Object? imageUrl = freezed,Object? description = freezed,Object? status = freezed,Object? createdAt = freezed,}) {
  return _then(_EventModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,externalId: null == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,artistName: freezed == artistName ? _self.artistName : artistName // ignore: cast_nullable_to_non_nullable
as String?,artistSpotifyId: freezed == artistSpotifyId ? _self.artistSpotifyId : artistSpotifyId // ignore: cast_nullable_to_non_nullable
as String?,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,eventDate: null == eventDate ? _self.eventDate : eventDate // ignore: cast_nullable_to_non_nullable
as DateTime,ticketUrl: freezed == ticketUrl ? _self.ticketUrl : ticketUrl // ignore: cast_nullable_to_non_nullable
as String?,priceMin: freezed == priceMin ? _self.priceMin : priceMin // ignore: cast_nullable_to_non_nullable
as double?,priceMax: freezed == priceMax ? _self.priceMax : priceMax // ignore: cast_nullable_to_non_nullable
as double?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
