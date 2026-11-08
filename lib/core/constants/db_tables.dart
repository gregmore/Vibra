/// Nomi delle tabelle (schema public) usate da Vibra su Supabase.
class DbTables {
  DbTables._();

  static const String users = 'users';
  static const String usersPublic = 'users_public';
  static const String musicProfiles = 'music_profiles';
  static const String musicProfilesPublic = 'music_profiles_public';
  static const String events = 'events';
  static const String eventAttendees = 'event_attendees';
  static const String friendships = 'friendships';
  static const String messages = 'messages';
  static const String liveMessages = 'live_messages';
  static const String notifications = 'notifications';
  static const String userMatches = 'user_matches';
  static const String userGenrePreferences = 'user_genre_preferences';
  static const String affinityDismissals = 'affinity_dismissals';
  static const String follows = 'follows';
  static const String musicalDnaSnapshots = 'musical_dna_snapshots';
  static const String privacyPreferences = 'privacy_preferences';
  static const String savedProfiles = 'saved_profiles';
}
