import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';

/// Default coordinates — Milano.
const double kDefaultLatitude = 45.4642;
const double kDefaultLongitude = 9.1900;

class UserLocation {
  const UserLocation({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;

  static const UserLocation milano = UserLocation(
    latitude: kDefaultLatitude,
    longitude: kDefaultLongitude,
  );
}

final userLocationProvider = FutureProvider<UserLocation>((ref) async {
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
    LocationPermission permission = await Geolocator.checkPermission();
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

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  } catch (e) {
    VibraLogger.error('GPS error, falling back to Milano', error: e);
    return UserLocation.milano;
  }
});
