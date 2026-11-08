import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/profile_identity.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/core_providers.dart';
import '../../providers/profile_identity_providers.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/profile_identity_widgets.dart';

/// Who can see each section of my profile (docs/profile-identity.md).
class ProfilePrivacyScreen extends ConsumerStatefulWidget {
  const ProfilePrivacyScreen({super.key});

  @override
  ConsumerState<ProfilePrivacyScreen> createState() =>
      _ProfilePrivacyScreenState();
}

class _ProfilePrivacyScreenState extends ConsumerState<ProfilePrivacyScreen> {
  final _local = <ProfileSection, SectionLevel>{};

  Future<void> _set(ProfileSection s, SectionLevel l, String me) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _local[s] = l);
    try {
      await ref.read(supabaseProfileIdentityDatasourceProvider).setLevel(s, l);
      ref.invalidate(profileIdentityProvider(me));
    } catch (_) {
      if (!mounted) return;
      setState(() => _local.remove(s));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profilePrivacyError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final theme = Theme.of(context);
    final me = ref
        .read(supabaseProfileIdentityDatasourceProvider)
        .currentUserId;
    if (me == null) return const SizedBox.shrink();
    final note = <ProfileSection, String>{
      ProfileSection.events: l10n.profilePrivacyEventsNote,
      ProfileSection.circles: l10n.profilePrivacyCirclesNote,
      ProfileSection.playlists: l10n.profilePrivacyPostsNote,
      ProfileSection.activity: l10n.profilePrivacyPostsNote,
    };
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.profilePrivacyTitle)),
      child: ref
          .watch(profileIdentityProvider(me))
          .when(
            loading: () => const VibraLoadingView(),
            error: (e, _) => VibraErrorView(
              error: e,
              title: l10n.profilePrivacyTitle,
              message: l10n.profilePrivacyError,
              retryLabel: l10n.commonRetry,
              onRetry: () => ref.invalidate(profileIdentityProvider(me)),
            ),
            data: (identity) => ListView(
              padding: const EdgeInsets.all(VibraSpacing.pagePadding),
              children: [
                Text(
                  l10n.profilePrivacyIntro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: t.textSecondary,
                  ),
                ),
                const SizedBox(height: VibraSpacing.lg),
                for (final s in ProfileSection.values) ...[
                  Row(
                    children: [
                      Icon(sectionIcon(s), size: 20, color: t.accentPrimary),
                      const SizedBox(width: VibraSpacing.sm),
                      Expanded(
                        child: Text(
                          sectionTitle(l10n, s),
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VibraSpacing.xs),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<SectionLevel>(
                      showSelectedIcon: false,
                      segments: [
                        for (final l in SectionLevel.values)
                          ButtonSegment(
                            value: l,
                            icon: Icon(levelIcon(l), size: 18),
                            label: Text(levelLabel(l10n, l)),
                          ),
                      ],
                      selected: {
                        _local[s] ??
                            identity?.levelOf(s) ??
                            SectionLevel.public,
                      },
                      onSelectionChanged: (v) => _set(s, v.first, me),
                    ),
                  ),
                  if (note[s] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: VibraSpacing.xs),
                      child: Text(
                        note[s]!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: t.textMuted,
                        ),
                      ),
                    ),
                  const SizedBox(height: VibraSpacing.lg),
                ],
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.donut_large_rounded,
                    color: t.accentPrimary,
                  ),
                  title: Text(l10n.musicalDnaProfileTile),
                  subtitle: Text(l10n.profilePrivacyDnaNote),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/musical-dna'),
                ),
              ],
            ),
          ),
    );
  }
}
