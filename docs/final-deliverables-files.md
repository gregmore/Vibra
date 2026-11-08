# Final deliverables: changed files

Every file changed in this implementation cycle, from `git status` on 2026-11-08 (nothing is committed yet). `A` = new, `M` = modified, `D` = deleted.

*(earlier, uncommitted)* marks files last changed before 2026-11-05: work from the October launch round (launch privacy, consent, Spotify pause, events catalogue; pgTAP 06–14) that was also never committed. They belong in a separate commit.
Total: 585 files.


## Database migrations (30)

- `A` supabase/migrations/20261013000000_launch_message_privacy.sql *(earlier, uncommitted)*
- `A` supabase/migrations/20261013000001_launch_location_and_spotify_consent.sql *(earlier, uncommitted)*
- `A` supabase/migrations/20261013000002_launch_spotify_pause.sql *(earlier, uncommitted)*
- `A` supabase/migrations/20261014000000_message_send_permission.sql *(earlier, uncommitted)*
- `A` supabase/migrations/20261014000001_events_catalogue.sql *(earlier, uncommitted)*
- `A` supabase/migrations/20261015000000_catalogue_worker_auth.sql *(earlier, uncommitted)*
- `A` supabase/migrations/20261105000000_event_map_result_limit.sql
- `A` supabase/migrations/20261105000001_spotify_sync_and_matching.sql
- `A` supabase/migrations/20261106000000_enable_spotify_public.sql
- `A` supabase/migrations/20261107000000_music_affinity_engine.sql
- `A` supabase/migrations/20261108000000_musical_dna.sql
- `A` supabase/migrations/20261109000000_same_frequency.sql
- `A` supabase/migrations/20261110000000_music_radar.sql
- `A` supabase/migrations/20261111000000_communities.sql
- `A` supabase/migrations/20261112000000_circles.sql
- `A` supabase/migrations/20261113000000_concert_intelligence.sql
- `A` supabase/migrations/20261114000000_whos_going.sql
- `A` supabase/migrations/20261115000000_concert_match.sql
- `A` supabase/migrations/20261116000000_daily_vibe.sql
- `A` supabase/migrations/20261117000000_music_stories.sql
- `A` supabase/migrations/20261118000000_vibra_feed.sql
- `A` supabase/migrations/20261119000000_track_reactions.sql
- `A` supabase/migrations/20261120000000_vibra_ai.sql
- `A` supabase/migrations/20261121000000_artist_discovery.sql
- `A` supabase/migrations/20261122000000_taste_evolution.sql
- `A` supabase/migrations/20261123000000_profile_identity.sql
- `A` supabase/migrations/20261124000000_social_safety.sql
- `A` supabase/migrations/20261125000000_notification_center.sql
- `A` supabase/migrations/20261126000000_schema_hardening.sql
- `A` supabase/migrations/20261127000000_performance.sql

## Edge Functions (68)

- `A` supabase/functions/_shared/ai/ai.test.ts
- `A` supabase/functions/_shared/ai/answer.ts
- `A` supabase/functions/_shared/ai/anthropic_provider.ts
- `A` supabase/functions/_shared/ai/provider.ts
- `A` supabase/functions/_shared/ai/supabase_data.ts
- `A` supabase/functions/_shared/ai/tools.ts
- `A` supabase/functions/_shared/ai/types.ts
- `A` supabase/functions/_shared/artist_discovery.test.ts
- `A` supabase/functions/_shared/artist_discovery.ts
- `A` supabase/functions/_shared/catalogue_auth.ts *(earlier, uncommitted)*
- `A` supabase/functions/_shared/event_recommendation.test.ts
- `A` supabase/functions/_shared/event_recommendation.ts
- `A` supabase/functions/_shared/feed_posts.test.ts
- `A` supabase/functions/_shared/feed_posts.ts
- `A` supabase/functions/_shared/genre_catalog.json
- `A` supabase/functions/_shared/genre_catalog.ts
- `A` supabase/functions/_shared/genre_taxonomy.ts
- `A` supabase/functions/_shared/music_affinity.test.ts
- `A` supabase/functions/_shared/music_affinity.ts
- `A` supabase/functions/_shared/music_match.ts
- `A` supabase/functions/_shared/music_stories.test.ts
- `A` supabase/functions/_shared/music_stories.ts
- `A` supabase/functions/_shared/music_sync.ts
- `A` supabase/functions/_shared/musical_dna.test.ts
- `A` supabase/functions/_shared/musical_dna.ts
- `A` supabase/functions/_shared/notification_delivery.test.ts
- `A` supabase/functions/_shared/notification_delivery.ts
- `A` supabase/functions/_shared/notification_worker_auth.test.ts *(earlier, uncommitted)*
- `A` supabase/functions/_shared/notification_worker_auth.ts *(earlier, uncommitted)*
- `A` supabase/functions/_shared/spotify-feature.test.ts
- `A` supabase/functions/_shared/spotify-feature.ts *(earlier, uncommitted)*
- `A` supabase/functions/_shared/spotify_api.test.ts
- `A` supabase/functions/_shared/spotify_api.ts
- `M` supabase/functions/_shared/spotify_app_token.ts *(earlier, uncommitted)*
- `A` supabase/functions/_shared/spotify_tracks.test.ts
- `A` supabase/functions/_shared/spotify_tracks.ts
- `A` supabase/functions/_shared/ticketmaster.test.ts
- `A` supabase/functions/_shared/ticketmaster.ts
- `A` supabase/functions/_shared/user_batches.test.ts
- `A` supabase/functions/_shared/user_batches.ts
- `M` supabase/functions/calculate-match/index.test.ts
- `M` supabase/functions/calculate-match/index.ts
- `M` supabase/functions/compute-event-embeddings/index.ts *(earlier, uncommitted)*
- `A` supabase/functions/daily-vibe/index.ts
- `A` supabase/functions/deno.lock
- `A` supabase/functions/discover-artists/index.ts
- `M` supabase/functions/event-reminders/index.ts
- `M` supabase/functions/event-reminders/reminder.test.ts
- `M` supabase/functions/event-reminders/reminder.ts
- `A` supabase/functions/feed-posts/index.ts
- `A` supabase/functions/media-purge/index.ts
- `A` supabase/functions/music-stories/index.ts
- `M` supabase/functions/recommend-events/index.ts
- `M` supabase/functions/retention-notifications/index.ts
- `A` supabase/functions/search-events/index.test.ts
- `A` supabase/functions/search-events/index.ts
- `M` supabase/functions/send-chat-notification/index.ts
- `M` supabase/functions/send-notifications/index.ts
- `M` supabase/functions/send-social-notification/index.ts
- `M` supabase/functions/spotify-disconnect/index.ts *(earlier, uncommitted)*
- `A` supabase/functions/spotify-sync-worker/index.ts
- `M` supabase/functions/spotify-token-exchange/index.ts
- `M` supabase/functions/sync-music-profile/genres.test.ts
- `M` supabase/functions/sync-music-profile/genres.ts
- `M` supabase/functions/sync-music-profile/index.ts
- `M` supabase/functions/ticketmaster-sync/index.ts
- `M` supabase/functions/upload-image/index.ts
- `A` supabase/functions/vibra-ai/index.ts

## Database tests (pgTAP) (13)

- `M` supabase/tests/database/05_push_consent_test.sql *(earlier, uncommitted)*
- `A` supabase/tests/database/06_launch_message_privacy_test.sql *(earlier, uncommitted)*
- `A` supabase/tests/database/07_launch_consent_test.sql *(earlier, uncommitted)*
- `A` supabase/tests/database/08_launch_match_consent_test.sql *(earlier, uncommitted)*
- `A` supabase/tests/database/09_launch_spotify_pause_test.sql *(earlier, uncommitted)*
- `A` supabase/tests/database/10_public_user_discovery_test.sql *(earlier, uncommitted)*
- `A` supabase/tests/database/11_message_send_permission_test.sql *(earlier, uncommitted)*
- `A` supabase/tests/database/12_support_report_submission_test.sql *(earlier, uncommitted)*
- `A` supabase/tests/database/13_event_catalogue_test.sql *(earlier, uncommitted)*
- `A` supabase/tests/database/14_catalogue_worker_auth_test.sql *(earlier, uncommitted)*
- `A` supabase/tests/database/15_music_affinity_test.sql
- `A` supabase/tests/database/16_social_cycle_test.sql
- `M` supabase/tests/pgtap_setup.inc *(earlier, uncommitted)*

## Supabase configuration (2)

- `M` supabase/PRODUCTION_SETUP.md
- `M` supabase/config.toml

## Localization (11)

- `M` lib/l10n/app_de.arb
- `M` lib/l10n/app_en.arb
- `M` lib/l10n/app_es.arb
- `M` lib/l10n/app_fr.arb
- `M` lib/l10n/app_it.arb
- `M` lib/l10n/app_localizations.dart
- `M` lib/l10n/app_localizations_de.dart
- `M` lib/l10n/app_localizations_en.dart
- `M` lib/l10n/app_localizations_es.dart
- `M` lib/l10n/app_localizations_fr.dart
- `M` lib/l10n/app_localizations_it.dart

## App core (21)

- `M` lib/core/config/push_notifications_bootstrap.dart
- `M` lib/core/constants/api_constants.dart
- `M` lib/core/constants/app_constants.dart
- `M` lib/core/constants/db_tables.dart
- `M` lib/core/errors/exceptions.dart *(earlier, uncommitted)*
- `A` lib/core/errors/offline.dart
- `A` lib/core/music/genre_catalog.dart
- `A` lib/core/music/genre_catalog.g.dart
- `A` lib/core/navigation/notification_routing.dart
- `M` lib/core/router/app_router.dart
- `M` lib/core/router/route_names.dart
- `M` lib/core/services/private_media_url.dart
- `M` lib/core/services/support_service.dart *(earlier, uncommitted)*
- `A` lib/core/theme/vibra_colors.dart
- `M` lib/core/theme/vibra_motion.dart
- `M` lib/core/theme/vibra_spacing.dart
- `M` lib/core/theme/vibra_text_styles.dart
- `M` lib/core/theme/vibra_theme.dart
- `M` lib/core/theme/vibra_theme_tokens.dart
- `A` lib/core/utils/geography.dart *(earlier, uncommitted)*
- `M` lib/core/utils/logger.dart

## Data layer (30)

- `A` lib/data/datasources/conversation_message_stream.dart *(earlier, uncommitted)*
- `M` lib/data/datasources/events_aggregator_datasource.dart *(earlier, uncommitted)*
- `M` lib/data/datasources/spotify_auth_datasource.dart
- `A` lib/data/datasources/supabase_artist_discovery_datasource.dart
- `A` lib/data/datasources/supabase_circles_datasource.dart
- `A` lib/data/datasources/supabase_communities_datasource.dart
- `A` lib/data/datasources/supabase_concerts_datasource.dart
- `A` lib/data/datasources/supabase_daily_vibe_datasource.dart
- `M` lib/data/datasources/supabase_datasource.dart
- `A` lib/data/datasources/supabase_event_social_datasource.dart
- `M` lib/data/datasources/supabase_events_datasource.dart
- `A` lib/data/datasources/supabase_feed_datasource.dart
- `M` lib/data/datasources/supabase_live_datasource.dart *(earlier, uncommitted)*
- `A` lib/data/datasources/supabase_music_radar_datasource.dart
- `A` lib/data/datasources/supabase_music_stories_datasource.dart
- `A` lib/data/datasources/supabase_musical_dna_datasource.dart
- `A` lib/data/datasources/supabase_notification_center_datasource.dart
- `M` lib/data/datasources/supabase_profile_datasource.dart *(earlier, uncommitted)*
- `A` lib/data/datasources/supabase_profile_identity_datasource.dart
- `A` lib/data/datasources/supabase_safety_datasource.dart
- `A` lib/data/datasources/supabase_same_frequency_datasource.dart
- `M` lib/data/datasources/supabase_social_datasource.dart
- `A` lib/data/datasources/supabase_vibra_ai_datasource.dart
- `M` lib/data/mappers/domain_mappers.dart
- `M` lib/data/models/event_model.dart
- `M` lib/data/models/event_model.freezed.dart
- `M` lib/data/models/event_model.g.dart
- `M` lib/data/models/notification_model.freezed.dart
- `M` lib/data/models/spotify_token_model.dart
- `M` lib/data/repositories/spotify_auth_repository_impl.dart

## Domain (27)

- `A` lib/domain/entities/artist_recommendation.dart
- `A` lib/domain/entities/circle.dart
- `A` lib/domain/entities/community.dart
- `A` lib/domain/entities/concert_match.dart
- `A` lib/domain/entities/daily_vibe.dart
- `A` lib/domain/entities/direct_message_permission.dart *(earlier, uncommitted)*
- `M` lib/domain/entities/event.dart
- `A` lib/domain/entities/event_recommendation.dart
- `A` lib/domain/entities/event_social.dart
- `A` lib/domain/entities/feed_post.dart
- `A` lib/domain/entities/inbox_notification.dart
- `M` lib/domain/entities/matched_user_preview.dart
- `A` lib/domain/entities/music_affinity.dart
- `A` lib/domain/entities/music_radar.dart
- `A` lib/domain/entities/music_reaction.dart
- `A` lib/domain/entities/music_story.dart
- `A` lib/domain/entities/musical_dna.dart
- `A` lib/domain/entities/profile_identity.dart
- `A` lib/domain/entities/safety.dart
- `A` lib/domain/entities/same_frequency.dart
- `M` lib/domain/entities/spotify_session.dart
- `A` lib/domain/entities/taste_evolution.dart
- `A` lib/domain/entities/vibra_ai.dart
- `M` lib/domain/repositories/spotify_auth_repository.dart
- `A` lib/domain/usecases/circle_suggestions.dart
- `A` lib/domain/usecases/community_recommendations.dart
- `A` lib/domain/usecases/same_frequency.dart

## Screens (51)

- `A` lib/presentation/screens/assistant/vibra_ai_screen.dart
- `M` lib/presentation/screens/auth/login_screen.dart
- `M` lib/presentation/screens/auth/splash_screen.dart
- `M` lib/presentation/screens/auth/spotify_connect_screen.dart
- `A` lib/presentation/screens/auth/spotify_unavailable_screen.dart *(earlier, uncommitted)*
- `M` lib/presentation/screens/auth/welcome_screen.dart
- `A` lib/presentation/screens/circles/circle_screen.dart
- `A` lib/presentation/screens/circles/circles_screen.dart
- `A` lib/presentation/screens/communities/communities_screen.dart
- `A` lib/presentation/screens/communities/community_moderation_screen.dart
- `A` lib/presentation/screens/communities/community_post_screen.dart
- `A` lib/presentation/screens/communities/community_screen.dart
- `A` lib/presentation/screens/discovery/discover_artists_screen.dart
- `M` lib/presentation/screens/event_detail/event_action_helpers.dart *(earlier, uncommitted)*
- `M` lib/presentation/screens/event_detail/event_detail_screen.dart
- `A` lib/presentation/screens/explore/concert_finder_screen.dart
- `A` lib/presentation/screens/explore/concert_match_screen.dart
- `M` lib/presentation/screens/explore/explore_screen.dart
- `A` lib/presentation/screens/feed/feed_composer_screen.dart
- `A` lib/presentation/screens/feed/feed_screen.dart
- `M` lib/presentation/screens/home/home_screen.dart
- `M` lib/presentation/screens/live/live_screen.dart
- `A` lib/presentation/screens/notifications/notification_center_screen.dart
- `M` lib/presentation/screens/onboarding/onboarding_wizard_screen.dart
- `M` lib/presentation/screens/profile/edit_profile_screen.dart
- `M` lib/presentation/screens/profile/help_center_screen.dart *(earlier, uncommitted)*
- `A` lib/presentation/screens/profile/music_genres_screen.dart
- `M` lib/presentation/screens/profile/music_stats_screen.dart *(earlier, uncommitted)*
- `A` lib/presentation/screens/profile/musical_dna_screen.dart
- `M` lib/presentation/screens/profile/my_profile_screen.dart
- `M` lib/presentation/screens/profile/privacy_controls_screen.dart
- `A` lib/presentation/screens/profile/profile_privacy_screen.dart
- `M` lib/presentation/screens/profile/report_problem_screen.dart *(earlier, uncommitted)*
- `A` lib/presentation/screens/profile/safety_center_screen.dart
- `M` lib/presentation/screens/profile/settings_screen.dart
- `A` lib/presentation/screens/profile/taste_evolution_screen.dart
- `M` lib/presentation/screens/profile/theme_appearance_selector.dart
- `M` lib/presentation/screens/shell/vibra_shell_screen.dart
- `M` lib/presentation/screens/social/chat_screen.dart
- `M` lib/presentation/screens/social/conversations_screen.dart
- `M` lib/presentation/screens/social/discover_users_screen.dart
- `M` lib/presentation/screens/social/follow_list_screen.dart
- `M` lib/presentation/screens/social/friends_screen.dart
- `A` lib/presentation/screens/social/music_radar_screen.dart
- `A` lib/presentation/screens/social/same_frequency_screen.dart
- `M` lib/presentation/screens/social/social_match_screen.dart
- `M` lib/presentation/screens/social/user_profile_screen.dart
- `A` lib/presentation/screens/stories/story_composer_screen.dart
- `A` lib/presentation/screens/stories/story_settings_screen.dart
- `A` lib/presentation/screens/stories/story_viewer_screen.dart
- `A` lib/presentation/screens/vibes/daily_vibe_screen.dart

## Widgets (48)

- `A` lib/presentation/widgets/affinity_explanation_card.dart
- `A` lib/presentation/widgets/artist_discovery_widgets.dart
- `A` lib/presentation/widgets/circle_widgets.dart
- `A` lib/presentation/widgets/common/vibra_auth_backdrop.dart
- `M` lib/presentation/widgets/common/vibra_avatar.dart
- `A` lib/presentation/widgets/common/vibra_badge.dart
- `A` lib/presentation/widgets/common/vibra_bottom_navigation.dart
- `A` lib/presentation/widgets/common/vibra_bottom_sheet.dart
- `M` lib/presentation/widgets/common/vibra_button.dart
- `M` lib/presentation/widgets/common/vibra_editorial_event.dart
- `M` lib/presentation/widgets/common/vibra_event_card.dart
- `A` lib/presentation/widgets/common/vibra_event_meta.dart
- `A` lib/presentation/widgets/common/vibra_image.dart
- `M` lib/presentation/widgets/common/vibra_input.dart
- `M` lib/presentation/widgets/common/vibra_logo.dart
- `A` lib/presentation/widgets/common/vibra_match_indicator.dart
- `M` lib/presentation/widgets/common/vibra_openstreetmap_layer.dart
- `M` lib/presentation/widgets/common/vibra_page_scaffold.dart
- `A` lib/presentation/widgets/common/vibra_paged_list.dart
- `M` lib/presentation/widgets/common/vibra_section_header.dart
- `A` lib/presentation/widgets/common/vibra_settings.dart
- `M` lib/presentation/widgets/common/vibra_state_views.dart
- `M` lib/presentation/widgets/common/vibra_surface.dart
- `M` lib/presentation/widgets/common/vibra_user_match_card.dart
- `A` lib/presentation/widgets/community_widgets.dart
- `A` lib/presentation/widgets/concert_widgets.dart
- `A` lib/presentation/widgets/daily_vibe_widgets.dart
- `M` lib/presentation/widgets/email_auth_sheet.dart
- `A` lib/presentation/widgets/feed_widgets.dart
- `A` lib/presentation/widgets/music_radar_widgets.dart
- `A` lib/presentation/widgets/music_reactions.dart
- `A` lib/presentation/widgets/music_story_widgets.dart
- `A` lib/presentation/widgets/musical_dna_widgets.dart
- `A` lib/presentation/widgets/notification_widgets.dart
- `A` lib/presentation/widgets/profile_identity_widgets.dart
- `A` lib/presentation/widgets/same_frequency_widgets.dart
- `M` lib/presentation/widgets/shared/user_avatar.dart *(earlier, uncommitted)*
- `M` lib/presentation/widgets/support_feedback_prompt.dart *(earlier, uncommitted)*
- `A` lib/presentation/widgets/taste_evolution_widgets.dart
- `M` lib/presentation/widgets/vibra_affinity_score.dart
- `A` lib/presentation/widgets/vibra_components.dart
- `A` lib/presentation/widgets/vibra_feature_components.dart
- `M` lib/presentation/widgets/vibra_glassmorphic_card.dart
- `M` lib/presentation/widgets/vibra_map_beacon.dart
- `M` lib/presentation/widgets/vibra_match_scanner.dart
- `M` lib/presentation/widgets/vibra_neon_avatar.dart
- `M` lib/presentation/widgets/vibra_pill_button.dart
- `A` lib/presentation/widgets/whos_going_section.dart

## Providers and localization helpers (30)

- `A` lib/presentation/localization/music_affinity_text.dart
- `A` lib/presentation/localization/user_facing_error.dart
- `M` lib/presentation/providers/app_state_providers.dart
- `M` lib/presentation/providers/app_synchronization_provider.dart *(earlier, uncommitted)*
- `A` lib/presentation/providers/artist_discovery_providers.dart
- `M` lib/presentation/providers/auth_provider.dart *(earlier, uncommitted)*
- `A` lib/presentation/providers/circle_providers.dart
- `A` lib/presentation/providers/community_providers.dart
- `A` lib/presentation/providers/concert_providers.dart
- `M` lib/presentation/providers/core_providers.dart
- `A` lib/presentation/providers/daily_vibe_providers.dart
- `A` lib/presentation/providers/direct_message_permission_provider.dart *(earlier, uncommitted)*
- `A` lib/presentation/providers/event_social_providers.dart
- `A` lib/presentation/providers/feed_providers.dart
- `A` lib/presentation/providers/live_events_provider.dart *(earlier, uncommitted)*
- `M` lib/presentation/providers/location_provider.dart *(earlier, uncommitted)*
- `M` lib/presentation/providers/map_events_provider.dart *(earlier, uncommitted)*
- `A` lib/presentation/providers/music_affinity_providers.dart
- `A` lib/presentation/providers/music_radar_providers.dart
- `A` lib/presentation/providers/music_story_providers.dart
- `A` lib/presentation/providers/musical_dna_providers.dart
- `A` lib/presentation/providers/notification_center_providers.dart
- `A` lib/presentation/providers/profile_identity_providers.dart
- `A` lib/presentation/providers/profile_photo_provider.dart *(earlier, uncommitted)*
- `A` lib/presentation/providers/public_friends_provider.dart *(earlier, uncommitted)*
- `A` lib/presentation/providers/public_users_provider.dart *(earlier, uncommitted)*
- `A` lib/presentation/providers/safety_providers.dart
- `A` lib/presentation/providers/same_frequency_providers.dart
- `M` lib/presentation/providers/spotify_auth_provider.dart
- `A` lib/presentation/providers/vibra_ai_providers.dart

## App (other) (1)

- `M` lib/main.dart

## Flutter tests (94)

- `A` test/core/account_deletion_test.dart *(earlier, uncommitted)*
- `A` test/core/artist_discovery_guarantees_test.dart
- `M` test/core/auth_boundary_test.dart
- `A` test/core/circles_consent_test.dart
- `A` test/core/communities_security_test.dart
- `A` test/core/concert_groups_moderation_test.dart
- `A` test/core/concert_match_privacy_test.dart
- `A` test/core/daily_vibe_licensing_test.dart
- `A` test/core/music_radar_privacy_test.dart
- `A` test/core/music_stories_privacy_test.dart
- `A` test/core/notification_center_guarantees_test.dart
- `A` test/core/performance_test.dart
- `A` test/core/profile_identity_guarantees_test.dart
- `A` test/core/public_legal_routes_test.dart *(earlier, uncommitted)*
- `A` test/core/rpc_contract_test.dart
- `A` test/core/schema_audit_test.dart
- `A` test/core/social_safety_guarantees_test.dart
- `A` test/core/spotify_connect_boundary_test.dart
- `D` test/core/spotify_refresh_boundary_test.dart
- `A` test/core/support_service_test.dart *(earlier, uncommitted)*
- `A` test/core/taste_evolution_guarantees_test.dart
- `M` test/core/theme/vibra_contrast_test.dart
- `M` test/core/theme/vibra_theme_test.dart
- `A` test/core/track_reactions_test.dart
- `A` test/core/vibra_ai_guarantees_test.dart
- `A` test/core/vibra_feed_guarantees_test.dart
- `A` test/core/whos_going_privacy_test.dart
- `M` test/data/avatar_upload_test.dart *(earlier, uncommitted)*
- `A` test/data/conversation_message_stream_test.dart *(earlier, uncommitted)*
- `A` test/data/direct_message_permission_test.dart *(earlier, uncommitted)*
- `A` test/data/nearby_event_cache_test.dart *(earlier, uncommitted)*
- `A` test/data/nearby_provider_search_test.dart *(earlier, uncommitted)*
- `A` test/data/profile_cache_boundary_test.dart *(earlier, uncommitted)*
- `A` test/data/public_users_search_test.dart *(earlier, uncommitted)*
- `A` test/domain/circle_suggestions_test.dart
- `A` test/domain/community_recommendations_test.dart
- `A` test/domain/feed_post_test.dart
- `A` test/domain/music_story_test.dart
- `A` test/domain/musical_dna_test.dart
- `A` test/domain/same_frequency_test.dart
- `A` test/domain/taste_evolution_test.dart
- `M` test/integration/security_idor_test.dart
- `A` test/presentation/localization/friends_loading_localization_test.dart *(earlier, uncommitted)*
- `A` test/presentation/localization/help_center_localization_test.dart *(earlier, uncommitted)*
- `A` test/presentation/localization/user_facing_error_test.dart *(earlier, uncommitted)*
- `A` test/presentation/providers/direct_message_permission_provider_test.dart *(earlier, uncommitted)*
- `A` test/presentation/providers/live_events_provider_test.dart *(earlier, uncommitted)*
- `A` test/presentation/providers/map_events_provider_test.dart *(earlier, uncommitted)*
- `A` test/presentation/providers/profile_controller_test.dart *(earlier, uncommitted)*
- `A` test/presentation/providers/public_friends_provider_test.dart
- `A` test/presentation/providers/public_users_provider_test.dart *(earlier, uncommitted)*
- `A` test/presentation/providers/social_follow_controller_test.dart *(earlier, uncommitted)*
- `A` test/presentation/providers/spotify_disabled_providers_test.dart
- `A` test/presentation/screens/chat_permission_test.dart *(earlier, uncommitted)*
- `A` test/presentation/screens/circles_screen_test.dart
- `A` test/presentation/screens/communities_screen_test.dart
- `A` test/presentation/screens/concert_finder_screen_test.dart
- `A` test/presentation/screens/concert_group_screen_test.dart
- `A` test/presentation/screens/concert_match_screen_test.dart
- `M` test/presentation/screens/conversations_screen_test.dart *(earlier, uncommitted)*
- `A` test/presentation/screens/daily_vibe_screen_test.dart
- `A` test/presentation/screens/discover_artists_screen_test.dart
- `M` test/presentation/screens/event_detail_actions_test.dart *(earlier, uncommitted)*
- `M` test/presentation/screens/experience_improvements_test.dart
- `M` test/presentation/screens/explore_screen_test.dart
- `A` test/presentation/screens/feed_screen_test.dart
- `A` test/presentation/screens/live_screen_test.dart *(earlier, uncommitted)*
- `A` test/presentation/screens/music_genres_screen_test.dart
- `A` test/presentation/screens/music_radar_screen_test.dart
- `M` test/presentation/screens/music_stats_screen_test.dart
- `A` test/presentation/screens/music_stories_screen_test.dart
- `A` test/presentation/screens/musical_dna_screen_test.dart
- `A` test/presentation/screens/notification_center_screen_test.dart
- `A` test/presentation/screens/profile_gallery_test.dart *(earlier, uncommitted)*
- `A` test/presentation/screens/report_problem_screen_test.dart *(earlier, uncommitted)*
- `A` test/presentation/screens/responsive_auth_test.dart *(earlier, uncommitted)*
- `A` test/presentation/screens/safety_center_screen_test.dart
- `A` test/presentation/screens/same_frequency_screen_test.dart
- `M` test/presentation/screens/send_vibra_test.dart
- `A` test/presentation/screens/spotify_disabled_launch_test.dart *(earlier, uncommitted)*
- `A` test/presentation/screens/taste_evolution_screen_test.dart
- `A` test/presentation/screens/vibra_ai_screen_test.dart
- `A` test/presentation/widgets/affinity_explanation_card_test.dart
- `A` test/presentation/widgets/email_auth_sheet_test.dart *(earlier, uncommitted)*
- `A` test/presentation/widgets/feature_components_test.dart
- `A` test/presentation/widgets/music_reactions_test.dart
- `A` test/presentation/widgets/profile_identity_test.dart
- `A` test/presentation/widgets/vibra_paged_list_test.dart
- `A` test/presentation/widgets/whos_going_section_test.dart
- `A` test/unit/music_affinity_test.dart
- `M` test/unit/spotify_account_link_verification_test.dart
- `M` test/widget/home_screen_smoke_test.dart *(earlier, uncommitted)*
- `M` test/widget/internal_buttons_smoke_test.dart
- `M` test/widget/splash_to_welcome_test.dart *(earlier, uncommitted)*

## Documentation (47)

- `A` docs/acceptance.md
- `A` docs/architecture.md
- `A` docs/artist-discovery.md
- `A` docs/backend-20261013.md *(earlier, uncommitted)*
- `A` docs/backend-spotify-pause-20261013.md *(earlier, uncommitted)*
- `A` docs/bugfixes-20261015.md *(earlier, uncommitted)*
- `A` docs/circles.md
- `A` docs/communities.md
- `A` docs/concert-groups.md
- `A` docs/concert-intelligence.md
- `A` docs/concert-match.md
- `A` docs/daily-vibe.md
- `A` docs/device-acceptance-20261018.md *(earlier, uncommitted)*
- `A` docs/google-android-launch-20261013.md *(earlier, uncommitted)*
- `A` docs/implementation-roadmap.md
- `A` docs/launch-closure-20261018.md *(earlier, uncommitted)*
- `A` docs/launch-readiness-20261013.md *(earlier, uncommitted)*
- `A` docs/localization-audit-20261014.md *(earlier, uncommitted)*
- `A` docs/music-affinity-engine.md
- `A` docs/music-radar.md
- `A` docs/music-stories.md
- `A` docs/musical-dna.md
- `A` docs/notification-center.md
- `A` docs/operations-runbook.md *(earlier, uncommitted)*
- `A` docs/operations-verification-20261018.md *(earlier, uncommitted)*
- `A` docs/performance.md
- `A` docs/profile-identity.md
- `A` docs/provider-readiness-20261013.md *(earlier, uncommitted)*
- `A` docs/push-readiness-20261018.md *(earlier, uncommitted)*
- `A` docs/safety.md
- `A` docs/same-frequency.md
- `A` docs/security/launch-20261013.md *(earlier, uncommitted)*
- `A` docs/security/launch-db-lint-20261013.json *(earlier, uncommitted)*
- `A` docs/security/launch-deno-check-20261013.txt *(earlier, uncommitted)*
- `A` docs/security/launch-deno-tests-20261013.txt *(earlier, uncommitted)*
- `A` docs/security/launch-pgtap-20261013.txt *(earlier, uncommitted)*
- `A` docs/spotify-integration.md
- `A` docs/spotify-public-access-draft-20261014.md
- `M` docs/store-materials-20261010.md *(earlier, uncommitted)*
- `M` docs/store-privacy-data.md *(earlier, uncommitted)*
- `A` docs/taste-evolution.md
- `A` docs/track-reactions.md
- `A` docs/ui-architecture.md
- `A` docs/ui-redesign-20261105.md
- `A` docs/vibra-ai.md
- `A` docs/vibra-feed.md
- `A` docs/whos-going.md

## CI (1)

- `M` .github/workflows/ci.yml

## Scripts (17)

- `A` script/branding/generate_brand_assets_test.dart
- `A` script/l10n/audit_localizations.py *(earlier, uncommitted)*
- `A` script/music/build_genre_catalog.py
- `M` script/release/build_store_release.sh *(earlier, uncommitted)*
- `A` script/release/deploy_spotify_affinity.sh
- `A` script/release/device_qa.example.json *(earlier, uncommitted)*
- `A` script/release/ios_signing.py *(earlier, uncommitted)*
- `M` script/release/preflight.py *(earlier, uncommitted)*
- `A` script/release/push_probe.py *(earlier, uncommitted)*
- `M` script/release/store_config.example.json
- `A` script/release/test_ios_signing.py *(earlier, uncommitted)*
- `A` script/security/test_database.sh *(earlier, uncommitted)*
- `M` script/store/build_site.py
- `A` script/store/capture_map_report_test.dart
- `M` script/store/capture_screenshots_test.dart
- `M` script/store/check_materials.py *(earlier, uncommitted)*
- `M` script/store/package_materials.py

## Android (35)

- `A` android/app/src/main/res/drawable-hdpi/android12splash.png
- `A` android/app/src/main/res/drawable-hdpi/splash.png
- `A` android/app/src/main/res/drawable-mdpi/android12splash.png
- `A` android/app/src/main/res/drawable-mdpi/splash.png
- `A` android/app/src/main/res/drawable-night-hdpi/android12splash.png
- `A` android/app/src/main/res/drawable-night-hdpi/splash.png
- `A` android/app/src/main/res/drawable-night-mdpi/android12splash.png
- `A` android/app/src/main/res/drawable-night-mdpi/splash.png
- `M` android/app/src/main/res/drawable-night-v21/background.png
- `M` android/app/src/main/res/drawable-night-v21/launch_background.xml
- `A` android/app/src/main/res/drawable-night-xhdpi/android12splash.png
- `A` android/app/src/main/res/drawable-night-xhdpi/splash.png
- `A` android/app/src/main/res/drawable-night-xxhdpi/android12splash.png
- `A` android/app/src/main/res/drawable-night-xxhdpi/splash.png
- `A` android/app/src/main/res/drawable-night-xxxhdpi/android12splash.png
- `A` android/app/src/main/res/drawable-night-xxxhdpi/splash.png
- `M` android/app/src/main/res/drawable-night/background.png
- `M` android/app/src/main/res/drawable-night/launch_background.xml
- `M` android/app/src/main/res/drawable-v21/background.png
- `M` android/app/src/main/res/drawable-v21/launch_background.xml
- `A` android/app/src/main/res/drawable-xhdpi/android12splash.png
- `A` android/app/src/main/res/drawable-xhdpi/splash.png
- `A` android/app/src/main/res/drawable-xxhdpi/android12splash.png
- `A` android/app/src/main/res/drawable-xxhdpi/splash.png
- `A` android/app/src/main/res/drawable-xxxhdpi/android12splash.png
- `A` android/app/src/main/res/drawable-xxxhdpi/splash.png
- `M` android/app/src/main/res/drawable/background.png
- `M` android/app/src/main/res/drawable/launch_background.xml
- `M` android/app/src/main/res/mipmap-hdpi/ic_launcher.png
- `M` android/app/src/main/res/mipmap-mdpi/ic_launcher.png
- `M` android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
- `M` android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
- `M` android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
- `M` android/app/src/main/res/values-night-v31/styles.xml
- `M` android/app/src/main/res/values-v31/styles.xml

## iOS (28)

- `A` ios/Flutter/sign_debug_framework.sh *(earlier, uncommitted)*
- `M` ios/Runner.xcodeproj/project.pbxproj
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
- `M` ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
- `M` ios/Runner/Assets.xcassets/LaunchBackground.imageset/background.png
- `M` ios/Runner/Assets.xcassets/LaunchBackground.imageset/darkbackground.png
- `M` ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json
- `M` ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png
- `M` ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png
- `M` ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png
- `A` ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImageDark.png
- `A` ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImageDark@2x.png
- `A` ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImageDark@3x.png
- `M` ios/Runner/Base.lproj/LaunchScreen.storyboard
- `A` ios/Runner/RunnerDebug.entitlements *(earlier, uncommitted)*

## Assets (10)

- `M` assets/branding/README.md
- `A` assets/branding/logo/vibra_mark.png
- `A` assets/branding/logo/vibra_splash_mark.png
- `M` assets/branding/raster/vibra_app_icon_1024.png
- `M` assets/branding/raster/vibra_play_feature_graphic_1024x500.png
- `A` assets/branding/source/vibra_logo_black_on_white_1024.jpg
- `A` assets/branding/source/vibra_logo_black_transparent_500.png
- `A` assets/branding/source/vibra_logo_white_on_black_1024.jpg
- `A` assets/branding/source/vibra_logo_white_transparent_500.png
- `M` assets/branding/vibra_app_icon.svg *(earlier, uncommitted)*

## Store materials (11)

- `M` store/README.md
- `M` store/owner.json
- `M` store/questionnaires/age-content-and-review.md
- `M` store/questionnaires/apple-app-privacy.json
- `M` store/questionnaires/apple-app-privacy.md
- `M` store/questionnaires/google-data-safety.md
- `M` store/site/dist/elimina-account.html
- `M` store/site/dist/index.html
- `M` store/site/dist/privacy.html
- `M` store/site/dist/supporto.html
- `M` store/site/dist/termini.html

## Repository root and other (10)

- `M` PRIVACY_POLICY.md
- `M` README.md *(earlier, uncommitted)*
- `M` RELEASE.md
- `M` STORE_METADATA.md
- `M` SUBMISSION_CHECKLIST.md
- `M` SUPPORT.md
- `M` TERMS_OF_SERVICE.md
- `A` build.yaml
- `M` flutter_native_splash.yaml
- `M` pubspec.yaml
