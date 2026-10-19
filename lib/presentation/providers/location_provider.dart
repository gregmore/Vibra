import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';

/// Default coordinates — Milano.
const double kDefaultLatitude = 45.4642;
const double kDefaultLongitude = 9.1900;

class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.isDeviceLocation = true,
  });
  final double latitude;
  final double longitude;

  /// False for the browsing fallback: it must never unlock nearby live chat.
  final bool isDeviceLocation;

  static const UserLocation milano = UserLocation(
    latitude: kDefaultLatitude,
    longitude: kDefaultLongitude,
    isDeviceLocation: false,
  );
}

final userLocationProvider = FutureProvider<UserLocation>((ref) async {
  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  try {
    // OS permission alone is not consent for Vibra's optional location
    // processing. Do not read device coordinates until the in-app choice is on.
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return UserLocation.milano;
    final preferences = await client
        .from('privacy_preferences')
        .select('location_processing')
        .eq('user_id', user.id)
        .maybeSingle();
    if (preferences?['location_processing'] != true) {
      return UserLocation.milano;
    }
    if (cancelled || client.auth.currentUser?.id != user.id) {
      return UserLocation.milano;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (cancelled || client.auth.currentUser?.id != user.id) {
      return UserLocation.milano;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      VibraLogger.warning(
        'GPS permission denied, using default location (Milano)',
      );
      return UserLocation.milano;
    }
    if (cancelled || client.auth.currentUser?.id != user.id) {
      return UserLocation.milano;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    if (cancelled || client.auth.currentUser?.id != user.id) {
      return UserLocation.milano;
    }
    try {
      // Live and nearby messaging enforce proximity against this private,
      // consent-bound server location, never the Milano browsing fallback.
      await client.rpc(
        'update_user_location',
        params: {'lon': position.longitude, 'lat': position.latitude},
      );
    } catch (error) {
      VibraLogger.error(
        'Impossibile aggiornare la posizione per Live',
        error: error,
      );
      // A revoked consent must also remove coordinates from this provider.
      // Server failure never unlocks proximity features with an unsaved fix.
      return UserLocation.milano;
    }
    if (cancelled || client.auth.currentUser?.id != user.id) {
      return UserLocation.milano;
    }
    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  } catch (e) {
    VibraLogger.error('GPS error, falling back to Milano', error: e);
    return UserLocation.milano;
  }
});
