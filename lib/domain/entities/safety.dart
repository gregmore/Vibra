/// Social safety (docs/safety.md).
class BlockedUser {
  const BlockedUser({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.blockedAt,
  });
  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? blockedAt;

  String get name =>
      displayName?.trim().isNotEmpty == true ? displayName!.trim() : username;
}

/// My own safety and privacy settings, in one read.
class SafetyOverview {
  const SafetyOverview({
    this.blockedCount = 0,
    this.reportsMade = 0,
    this.locationProcessing = false,
    this.radarEnabled = false,
    this.radarVisible = true,
    this.dnaVisibility = 'private',
    this.attendanceVisibility = 'private',
    this.musicMatching = false,
    this.aiAssistant = false,
    this.tasteHistory = true,
    this.storyAudience = 'connections',
    this.hiddenStoryViewers = 0,
  });

  final int blockedCount;
  final int reportsMade;
  final bool locationProcessing;
  final bool radarEnabled;
  final bool radarVisible;
  final String dnaVisibility;
  final String attendanceVisibility;
  final bool musicMatching;
  final bool aiAssistant;
  final bool tasteHistory;
  final String storyAudience;
  final int hiddenStoryViewers;

  static SafetyOverview fromJson(Object? raw) {
    if (raw is! Map) return const SafetyOverview();
    int n(Object? v) => (v as num?)?.toInt() ?? 0;
    return SafetyOverview(
      blockedCount: n(raw['blocked_count']),
      reportsMade: n(raw['reports_made']),
      locationProcessing: raw['location_processing'] == true,
      radarEnabled: raw['radar_enabled'] == true,
      radarVisible: raw['radar_visible'] != false,
      dnaVisibility: raw['musical_dna_visibility']?.toString() ?? 'private',
      attendanceVisibility:
          raw['attendance_visibility']?.toString() ?? 'private',
      musicMatching: raw['spotify_matching'] == true,
      aiAssistant: raw['ai_assistant'] == true,
      tasteHistory: raw['taste_history'] != false,
      storyAudience:
          raw['story_default_visibility']?.toString() ?? 'connections',
      hiddenStoryViewers: n(raw['hidden_story_viewers']),
    );
  }
}

/// A server error explained to the user (reports and blocks).
enum SafetyError { duplicateReport, rateLimited, unavailable, failed }

SafetyError safetyErrorOf(Object e) {
  final m = '$e';
  if (m.contains('duplicate_report')) return SafetyError.duplicateReport;
  if (m.contains('PT429') || m.contains('limit')) {
    return SafetyError.rateLimited;
  }
  if (m.contains('user_unavailable')) return SafetyError.unavailable;
  return SafetyError.failed;
}
