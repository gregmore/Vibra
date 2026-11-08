import '../../widgets/whos_going_section.dart';
import '../../providers/event_social_providers.dart';
import '../../../core/constants/app_constants.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/usecases/events_usecases.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/app_synchronization_provider.dart';
import '../../providers/usecase_providers.dart';
import '../../providers/core_providers.dart';
import 'package:vibra/l10n/app_localizations.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_event_meta.dart';
import '../../widgets/common/vibra_image.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/vibra_map_beacon.dart';
import '../../widgets/common/vibra_openstreetmap_layer.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_user_match_card.dart';
import 'event_action_helpers.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final Event? event;
  const EventDetailScreen({super.key, this.event});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  String? _attendanceStatus;
  String? _savingAttendanceStatus;
  String? _loadedAttendanceEventKey;
  bool _loadingAttendance = false;
  bool _openingTickets = false;

  void _showFeedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _trackTicketClick(Event event) async {
    try {
      await ref
          .read(supabaseDatasourceProvider)
          .client
          .functions
          .invoke('track-ticket-click', body: {'event_id': event.id});
    } catch (error) {
      debugPrint('Tracking error: $error');
    }
  }

  Future<void> _openTickets(Event event) async {
    if (_openingTickets) return;
    final l10n = AppLocalizations.of(context)!;
    final uri = eventTicketUri(event);
    if (uri == null) {
      _showFeedback(l10n.eventDetailTicketsUnavailable);
      return;
    }
    setState(() => _openingTickets = true);
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!mounted) return;
      if (opened) {
        unawaited(_trackTicketClick(event));
      } else {
        _showFeedback(l10n.eventDetailTicketsError);
      }
    } catch (_) {
      _showFeedback(l10n.eventDetailTicketsError);
    } finally {
      if (mounted) setState(() => _openingTickets = false);
    }
  }

  Future<void> _openDirections(Event event) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = eventDirectionsUri(event);
    if (uri == null) return;
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showFeedback(l10n.eventDirectionsError);
      }
    } catch (_) {
      _showFeedback(l10n.eventDirectionsError);
    }
  }

  Future<void> _copyDetails(Event event) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    try {
      await Clipboard.setData(
        ClipboardData(text: eventDetailsText(event, locale)),
      );
      _showFeedback(l10n.eventDetailCopied);
    } catch (_) {
      _showFeedback(l10n.eventCopyError);
    }
  }

  void _ensureAttendanceLoaded(Event event) {
    final eventKey = '${event.source}:${event.externalId}';
    if (_loadedAttendanceEventKey == eventKey) return;
    _loadedAttendanceEventKey = eventKey;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _loadedAttendanceEventKey != eventKey) return;
      setState(() {
        _loadingAttendance = true;
        _attendanceStatus = null;
      });

      try {
        final status = await ref
            .read(getMyEventAttendanceUseCaseProvider)
            .call(event);
        if (mounted && _loadedAttendanceEventKey == eventKey) {
          setState(() => _attendanceStatus = status);
        }
      } catch (_) {
        // La schermata resta utilizzabile anche se il recupero non riesce.
      } finally {
        if (mounted && _loadedAttendanceEventKey == eventKey) {
          setState(() => _loadingAttendance = false);
        }
      }
    });
  }

  Future<void> _setAttendance(Event event, String status) async {
    if (_savingAttendanceStatus != null) return;

    setState(() => _savingAttendanceStatus = status);
    final l10n = AppLocalizations.of(context)!;

    try {
      await ref
          .read(setEventAttendanceUseCaseProvider)
          .call(SetEventAttendanceParams(event: event, status: status));
      ref
          .read(appSynchronizationProvider)
          .eventAttendanceChanged(event, status);
      if (!mounted) return;

      setState(() => _attendanceStatus = status);
      final message = switch (status) {
        'going' => l10n.eventDetailAttendanceConfirmed,
        'maybe' => l10n.eventDetailAttendanceMaybe,
        'interested' => l10n.eventDetailAttendanceInterested,
        'none' => l10n.eventDetailAttendanceRemoved,
        _ => l10n.eventDetailAttendanceNotGoing,
      };
      // Own state and the visible list both changed.
      ref.invalidate(myAttendanceProvider);
      ref.invalidate(eventSocialProvider);
      ref.invalidate(eventCatalogueIdProvider);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${l10n.authGenericError}. ${l10n.commonRetry}.'),
          ),
        );
    } finally {
      if (mounted) setState(() => _savingAttendanceStatus = null);
    }
  }

  ButtonStyle _attendanceButtonStyle(String status) {
    final t = context.vibraTokens;
    final selected = _attendanceStatus == status;
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      minimumSize: const Size(0, VibraSpacing.buttonHeightCompact + 4),
      backgroundColor: selected ? t.accentSoft : t.surface,
      foregroundColor: t.textPrimary,
      shape: RoundedRectangleBorder(borderRadius: VibraSpacing.borderMedium),
      side: BorderSide(
        color: selected ? t.accentPrimary : t.borderDefault,
        width: selected ? 1.5 : 1,
      ),
    );
  }

  Widget _attendanceButtonChild(String label, String status) {
    final t = context.vibraTokens;
    if (_savingAttendanceStatus == status) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: t.textPrimary),
      );
    }
    final selected = _attendanceStatus == status;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selected) ...[
          Icon(Icons.check_rounded, size: 16, color: t.accentPrimary),
          const SizedBox(width: 3),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: VibraTextStyles.labelMedium.copyWith(color: t.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _attendanceButton(Event event, String label, String status) {
    final selected = _attendanceStatus == status;
    return Expanded(
      flex: 3,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: OutlinedButton(
          style: _attendanceButtonStyle(status),
          onPressed: !_loadingAttendance && _savingAttendanceStatus == null
              ? () => _setAttendance(
                  event,
                  _attendanceStatus == status ? 'none' : status,
                )
              : null,
          child: _attendanceButtonChild(label, status),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featured = ref.watch(featuredEventsProvider);
    final displayEvent =
        widget.event ?? (featured.isNotEmpty ? featured.first : null);
    final users = ref.watch(matchedUsersProvider);
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;

    if (displayEvent == null) {
      return VibraPageScaffold(
        child: VibraEmptyView(
          title: l10n.eventDetailNotAvailableTitle,
          message: l10n.eventDetailNotAvailableMsg,
          icon: Icons.event_busy_rounded,
          actionLabel: l10n.navEvents,
          onActionTap: () => context.go('/explore'),
        ),
      );
    }

    _ensureAttendanceLoaded(displayEvent);
    final coordinates = eventCoordinates(displayEvent);

    final status = vibraEventStatus(displayEvent);
    final date = VibraEventDate(context, displayEvent.eventDate);
    final price = _priceRange(context, displayEvent);
    final place = eventPlaceLabel(displayEvent);
    final ticketsBlocked =
        status == VibraEventStatus.cancelled ||
        status == VibraEventStatus.offSale;
    final heroHeight = (MediaQuery.sizeOf(context).height * .42).clamp(
      260.0,
      400.0,
    );

    return VibraPageScaffold(
      useGradient: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: VibraSpacing.huge),
        children: [
          // ── Hero artwork ────────────────────────────────────
          SizedBox(
            height: heroHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: VibraSpacing.md,
                  ),
                  child: ClipRRect(
                    borderRadius: VibraSpacing.borderXL,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        VibraNetworkImage(
                          url: displayEvent.imageUrl,
                          cacheWidth: 520,
                        ),
                        VibraImageScrim(color: t.imageOverlay, start: .45),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: VibraSpacing.sm,
                  left: VibraSpacing.lg + VibraSpacing.xs,
                  child: _HeroIconButton(
                    tooltip: AppLocalizations.of(context)!.eventBackToEvents,
                    icon: Icons.arrow_back_rounded,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/explore');
                      }
                    },
                  ),
                ),
                Positioned(
                  top: VibraSpacing.sm,
                  right: VibraSpacing.lg + VibraSpacing.xs,
                  child: _HeroIconButton(
                    tooltip: l10n.eventCopyDetails,
                    icon: Icons.ios_share_rounded,
                    onPressed: () => _copyDetails(displayEvent),
                  ),
                ),
                Positioned(
                  left: VibraSpacing.xxl + VibraSpacing.xs,
                  right: VibraSpacing.xxl + VibraSpacing.xs,
                  bottom: VibraSpacing.xl,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _DateBlock(date: date),
                      const Spacer(),
                      if (status != VibraEventStatus.upcoming)
                        VibraEventStatusBadge(status: status),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Title block ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.xxl,
              VibraSpacing.pagePadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (displayEvent.artistName?.trim().isNotEmpty == true &&
                    displayEvent.artistName != displayEvent.name) ...[
                  Text(
                    displayEvent.artistName!.toUpperCase(),
                    style: VibraTextStyles.labelSmall.copyWith(
                      color: t.accentPrimary,
                    ),
                  ),
                  const SizedBox(height: VibraSpacing.sm),
                ],
                Semantics(
                  header: true,
                  child: Text(
                    displayEvent.name,
                    style: VibraTextStyles.headlineLarge.copyWith(
                      color: t.textPrimary,
                      decoration: status == VibraEventStatus.cancelled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Key facts ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.xl,
              VibraSpacing.pagePadding,
              0,
            ),
            child: VibraSurface(
              padding: const EdgeInsets.symmetric(
                horizontal: VibraSpacing.lg,
                vertical: VibraSpacing.xs,
              ),
              child: Column(
                children: [
                  _FactRow(
                    icon: Icons.calendar_today_rounded,
                    title: DateFormat.yMMMMEEEEd(
                      Localizations.localeOf(context).toString(),
                    ).format(displayEvent.eventDate.toLocal()),
                    subtitle: date.time,
                  ),
                  if (place.isNotEmpty || coordinates == null) ...[
                    Divider(color: t.borderDefault, height: 1),
                    _FactRow(
                      icon: Icons.place_outlined,
                      title:
                          displayEvent.venueName ??
                          (place.isNotEmpty ? place : l10n.eventVenueTBA),
                      subtitle: coordinates == null
                          ? l10n.eventLocationUnknown
                          : [displayEvent.city, displayEvent.country]
                                .whereType<String>()
                                .where((s) => s.isNotEmpty)
                                .join(', '),
                    ),
                  ],
                  if (price != null) ...[
                    Divider(color: t.borderDefault, height: 1),
                    _FactRow(
                      icon: Icons.confirmation_number_outlined,
                      title: price,
                      subtitle: l10n.eventPrice,
                    ),
                  ],
                  // Published classification genres, exactly as given.
                  if (displayEvent.genres.isNotEmpty) ...[
                    Divider(color: t.borderDefault, height: 1),
                    _FactRow(
                      icon: Icons.graphic_eq_rounded,
                      title: displayEvent.genres.take(3).join(' · '),
                      subtitle: l10n.concertFilterGenre,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Primary action ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              VibraSpacing.pagePadding,
              VibraSpacing.xl,
              VibraSpacing.pagePadding,
              VibraSpacing.md,
            ),
            child: SizedBox(
              width: double.infinity,
              height: VibraSpacing.buttonHeight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ticketsBlocked
                      ? t.surfaceMuted
                      : t.accentFill,
                  foregroundColor: ticketsBlocked
                      ? t.textSecondary
                      : t.onAccent,
                ),
                onPressed: _openingTickets
                    ? null
                    : () => _openTickets(displayEvent),
                icon: _openingTickets
                    ? const SizedBox.shrink()
                    : Icon(
                        ticketsBlocked
                            ? Icons.block_rounded
                            : Icons.confirmation_number_rounded,
                        size: VibraSpacing.iconMd,
                      ),
                label: _openingTickets
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: t.onAccent,
                        ),
                      )
                    : Text(
                        const {
                              'canceled',
                              'cancelled',
                            }.contains(displayEvent.status)
                            ? l10n.eventCancelled
                            : displayEvent.status == 'offsale'
                            ? l10n.eventTicketsOffsale
                            : l10n.eventDetailBuyTickets,
                      ),
              ),
            ),
          ),
          Padding(
            padding: VibraSpacing.pageHorizontal,
            child: Row(
              children: [
                _attendanceButton(
                  displayEvent,
                  l10n.eventDetailInterested,
                  'interested',
                ),
                const SizedBox(width: VibraSpacing.sm),
                _attendanceButton(displayEvent, l10n.eventDetailMaybe, 'maybe'),
                const SizedBox(width: VibraSpacing.sm),
                _attendanceButton(
                  displayEvent,
                  l10n.eventDetailAttend,
                  'going',
                ),
              ],
            ),
          ),

          // ── Who's going? ────────────────────────────────────
          if (AppConstants.spotifyEnabled)
            WhosGoingSection(event: displayEvent),

          // ── About ───────────────────────────────────────────
          if (_cleanDescription(displayEvent.description ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.sectionGap,
                VibraSpacing.pagePadding,
                0,
              ),
              child: _TranslatedDescription(
                text: _cleanDescription(displayEvent.description ?? ''),
              ),
            ),

          // ── Location ────────────────────────────────────────
          if (coordinates != null)
            VibraSectionHeader(
              title: AppLocalizations.of(context)!.eventDetailMapTitle,
              subtitle: AppLocalizations.of(context)!.eventDetailMapSub,
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.sectionGap,
                VibraSpacing.pagePadding,
                VibraSpacing.md,
              ),
            ),
          if (coordinates != null)
            Container(
              height: 200,
              margin: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                0,
                VibraSpacing.pagePadding,
                VibraSpacing.md,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: VibraSpacing.borderLarge,
                border: Border.all(color: t.borderDefault),
              ),
              child: FlutterMap(
                options: MapOptions(
                  onTap: (_, _) => _openDirections(displayEvent),
                  initialCenter: LatLng(
                    coordinates.latitude,
                    coordinates.longitude,
                  ),
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  const VibraOpenStreetMapTileLayer(),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          coordinates.latitude,
                          coordinates.longitude,
                        ),
                        width: 58,
                        height: 58,
                        child: const IgnorePointer(
                          child: VibraMapBeacon(selected: true, pulse: false),
                        ),
                      ),
                    ],
                  ),
                  const VibraOpenStreetMapAttribution(),
                ],
              ),
            ),
          if (coordinates == null && eventDirectionsUri(displayEvent) != null)
            const SizedBox(height: VibraSpacing.xl),
          if (eventDirectionsUri(displayEvent) != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VibraSpacing.pagePadding,
              ),
              child: VibraButton(
                label: l10n.eventDirections,
                onPressed: () => _openDirections(displayEvent),
                tone: VibraButtonTone.outline,
                size: VibraButtonSize.compact,
                leadingIcon: Icons.directions_rounded,
                expanded: true,
              ),
            ),

          // ── People ──────────────────────────────────────────
          if (users.isNotEmpty)
            VibraSectionHeader(
              title: l10n.socialDiscoverUsers,
              subtitle: AppConstants.spotifyEnabled
                  ? l10n.socialHighCompatibility
                  : l10n.launchCommunitySubtitle,
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.sectionGap,
                VibraSpacing.pagePadding,
                VibraSpacing.sm,
              ),
            ),
          ...users.map(
            (user) => VibraUserMatchCard(
              user: user,
              onTap: () => context.push('/user-profile', extra: user.user.id),
              trailing: VibraIconButton(
                icon: Icons.chat_bubble_outline_rounded,
                tooltip: l10n.eventDetailChat,
                tone: VibraButtonTone.signal,
                size: 44,
                onPressed: () => context.push(
                  '/chat',
                  extra: {
                    'otherUserId': user.user.id,
                    'otherDisplayName':
                        user.user.displayName ?? user.user.username,
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _priceRange(BuildContext context, Event event) {
    final min = vibraFormatPrice(context, event, event.priceMin);
    final max = vibraFormatPrice(context, event, event.priceMax);
    if (min == null && max == null) return null;
    if (min != null && max != null && min != max) return '$min – $max';
    return min ?? max;
  }

  String _cleanDescription(String text) {
    if (text.isEmpty) return '';
    // Rimuove eventuali tag genere come "[Genre / Subgenre]" all'inizio
    final RegExp exp = RegExp(r'^\[.*?\]\s*\n*');
    return text.replaceAll(exp, '').trim();
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: t.imageOverlay,
        foregroundColor: t.onImage,
      ),
      icon: Icon(icon, size: VibraSpacing.iconMd),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.date});

  final VibraEventDate date;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date.day,
          style: VibraTextStyles.displayMedium.copyWith(
            color: t.onImage,
            height: 1,
          ),
        ),
        Text(
          '${date.month} · ${date.weekday.toUpperCase()}',
          style: VibraTextStyles.labelSmall.copyWith(color: t.onImageMuted),
        ),
      ],
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VibraSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.surfaceMuted,
              borderRadius: VibraSpacing.borderSmall,
            ),
            child: Icon(
              icon,
              size: VibraSpacing.iconMd,
              color: t.accentPrimary,
            ),
          ),
          const SizedBox(width: VibraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: VibraTextStyles.titleSmall.copyWith(
                    color: t.textPrimary,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: VibraTextStyles.bodySmall.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslatedDescription extends ConsumerStatefulWidget {
  final String text;
  const _TranslatedDescription({required this.text});

  @override
  ConsumerState<_TranslatedDescription> createState() =>
      _TranslatedDescriptionState();
}

class _TranslatedDescriptionState
    extends ConsumerState<_TranslatedDescription> {
  String? _translatedText;
  bool _isLoading = true;

  String? _targetLang;
  int _translationGeneration = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLang = Localizations.localeOf(context).languageCode;
    if (_targetLang != newLang) {
      _targetLang = newLang;
      _translate();
    }
  }

  @override
  void didUpdateWidget(covariant _TranslatedDescription oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _translate();
    }
  }

  Future<void> _translate() async {
    if (_targetLang == null) return;
    setState(() => _isLoading = true);

    final generation = ++_translationGeneration;
    final sourceText = widget.text;
    final targetLanguage = _targetLang!;
    try {
      final translator = GoogleTranslator();
      final translation = await translator.translate(
        sourceText,
        to: targetLanguage,
      );
      if (mounted && generation == _translationGeneration) {
        setState(() {
          _translatedText = translation.text;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && generation == _translationGeneration) {
        setState(() {
          _translatedText = widget.text;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;

    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(t.accentPrimary),
          ),
        ),
      );
    }

    return Text(
      _translatedText ?? widget.text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: t.textSecondary,
        height: 1.6,
      ),
    );
  }
}
