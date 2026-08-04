import '../../domain/entities/app_notification.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/direct_message.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/friendship.dart';
import '../../domain/entities/live_message.dart';
import '../../domain/entities/music_profile.dart';
import '../models/event_attendee_model.dart';
import '../models/event_model.dart';
import '../models/friendship_model.dart';
import '../models/live_message_model.dart';
import '../models/message_model.dart';
import '../models/music_profile_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

extension UserModelToEntity on UserModel {
  AppUser toEntity() {
    return AppUser(
      id: id,
      email: email,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      spotifyId: spotifyId,
      fcmToken: fcmToken,
      onboardingCompleted: onboardingCompleted,
      onboardingStep: onboardingStep,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension UserEntityToModel on AppUser {
  UserModel toModel({String? spotifyAccessToken, String? spotifyRefreshToken}) {
    return UserModel(
      id: id,
      email: email,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      spotifyId: spotifyId,
      fcmToken: fcmToken,
      onboardingCompleted: onboardingCompleted,
      onboardingStep: onboardingStep,
      spotifyAccessToken: spotifyAccessToken,
      spotifyRefreshToken: spotifyRefreshToken,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension MusicProfileModelToEntity on MusicProfileModel {
  MusicProfile toEntity() {
    return MusicProfile(
      id: id,
      userId: userId,
      topArtists: topArtists
          .map(
            (item) => MusicArtistPreference(
              id: (item['id'] ?? '').toString(),
              name: (item['name'] ?? '').toString(),
              score: (item['score'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList(growable: false),
      topTracks: topTracks
          .map(
            (item) => MusicTrackPreference(
              id: (item['id'] ?? '').toString(),
              name: (item['name'] ?? '').toString(),
              artist: item['artist']?.toString(),
              score: (item['score'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList(growable: false),
      topGenres: topGenres
          .map(
            (item) => GenrePreference(
              genre: (item['genre'] ?? '').toString(),
              weight: (item['weight'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList(growable: false),
      lastSyncedAt: lastSyncedAt,
    );
  }
}

extension MusicProfileEntityToModel on MusicProfile {
  MusicProfileModel toModel() {
    return MusicProfileModel(
      id: id,
      userId: userId,
      topArtists: topArtists
          .map(
            (item) => {'id': item.id, 'name': item.name, 'score': item.score},
          )
          .toList(growable: false),
      topTracks: topTracks
          .map(
            (item) => {
              'id': item.id,
              'name': item.name,
              'artist': item.artist,
              'score': item.score,
            },
          )
          .toList(growable: false),
      topGenres: topGenres
          .map((item) => {'genre': item.genre, 'weight': item.weight})
          .toList(growable: false),
      lastSyncedAt: lastSyncedAt,
    );
  }
}

extension EventModelToEntity on EventModel {
  Event toEntity() {
    return Event(
      id: id,
      externalId: externalId,
      source: source,
      name: name,
      artistName: artistName,
      artistSpotifyId: artistSpotifyId,
      venueName: venueName,
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      eventDate: eventDate,
      ticketUrl: ticketUrl,
      priceMin: priceMin,
      priceMax: priceMax,
      imageUrl: imageUrl,
      description: description,
      createdAt: createdAt,
    );
  }
}

extension EventEntityToModel on Event {
  EventModel toModel() {
    return EventModel(
      id: id,
      externalId: externalId,
      source: source,
      name: name,
      artistName: artistName,
      artistSpotifyId: artistSpotifyId,
      venueName: venueName,
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
      eventDate: eventDate,
      ticketUrl: ticketUrl,
      priceMin: priceMin,
      priceMax: priceMax,
      imageUrl: imageUrl,
      description: description,
      createdAt: createdAt,
    );
  }
}

extension EventAttendeeModelToEntity on EventAttendeeModel {
  EventAttendee toEntity() {
    return EventAttendee(
      id: id,
      userId: userId,
      eventId: eventId,
      status: status,
      createdAt: createdAt,
    );
  }
}

extension FriendshipModelToEntity on FriendshipModel {
  Friendship toEntity() {
    return Friendship(
      id: id,
      requesterId: requesterId,
      receiverId: receiverId,
      status: status,
      createdAt: createdAt,
    );
  }
}

extension MessageModelToEntity on MessageModel {
  DirectMessage toEntity() {
    return DirectMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      messageType: messageType,
      metadata: metadata,
      reactions: reactions,
      deletedBy: deletedBy,
      readAt: readAt,
      createdAt: createdAt,
    );
  }
}

extension LiveMessageModelToEntity on LiveMessageModel {
  LiveMessage toEntity() {
    return LiveMessage(
      id: id,
      eventId: eventId,
      userId: userId,
      content: content,
      createdAt: createdAt,
    );
  }
}

extension NotificationModelToEntity on NotificationModel {
  AppNotification toEntity() {
    return AppNotification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      data: data,
      read: read,
      createdAt: createdAt,
    );
  }
}
