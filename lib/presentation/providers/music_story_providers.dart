import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/music_story.dart';
import 'core_providers.dart';

/// Music Stories (docs/music-stories.md).
final storyRingProvider = FutureProvider.autoDispose<List<StoryRingEntry>>(
  (ref) => ref.watch(supabaseMusicStoriesDatasourceProvider).ring(),
);

final userStoriesProvider = FutureProvider.autoDispose
    .family<List<MusicStory>, String>(
      (ref, userId) =>
          ref.watch(supabaseMusicStoriesDatasourceProvider).storiesOf(userId),
    );

final storyViewersProvider = FutureProvider.autoDispose
    .family<List<StoryPerson>, String>(
      (ref, storyId) =>
          ref.watch(supabaseMusicStoriesDatasourceProvider).viewers(storyId),
    );

final storyRepliesProvider = FutureProvider.autoDispose
    .family<List<StoryReply>, String>(
      (ref, storyId) =>
          ref.watch(supabaseMusicStoriesDatasourceProvider).replies(storyId),
    );

final storySettingsProvider = FutureProvider.autoDispose<StorySettings>(
  (ref) => ref.watch(supabaseMusicStoriesDatasourceProvider).settings(),
);

final storyAudienceProvider = FutureProvider.autoDispose<List<StoryPerson>>(
  (ref) => ref.watch(supabaseMusicStoriesDatasourceProvider).audience(),
);
