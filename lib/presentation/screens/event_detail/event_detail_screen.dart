import '../../../core/constants/app_constants.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/usecases/events_usecases.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/app_synchronization_provider.dart';
import '../../providers/usecase_providers.dart';
import '../../providers/core_providers.dart';
import 'package:vibra/l10n/app_localizations.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
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
        _ => l10n.eventDetailAttendanceNotGoing,
      };
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
      padding: const EdgeInsets.symmetric(horizontal: 2),
      minimumSize: const Size(0, 48),
      backgroundColor: selected ? t.accentSoft : Colors.transparent,
      foregroundColor: t.textPrimary,
      side: BorderSide(
        color: selected ? t.accentPrimary : t.borderStrong,
        width: selected ? 2 : 1,
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
          Icon(Icons.check_rounded, size: 16, color: t.textPrimary),
          const SizedBox(width: 3),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
              ? () => _setAttendance(event, status)
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
    final theme = Theme.of(context);
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

    return VibraPageScaffold(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Stack(
            children: [
              SizedBox(
                height: 320,
                width: double.infinity,
                child: displayEvent.imageUrl?.trim().isNotEmpty == true
                    ? CachedNetworkImage(
                        imageUrl: displayEvent.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: t.shimmerBase,
                          highlightColor: t.shimmerHighlight,
                          child: Container(color: t.surfaceElevated),
                        ),
                        errorWidget: (context, url, error) =>
                            Container(color: t.surfaceMuted),
                      )
                    : ColoredBox(
                        color: t.surfaceMuted,
                        child: Icon(
                          Icons.music_note_rounded,
                          size: 64,
                          color: t.textSecondary,
                        ),
                      ),
              ),
              Positioned.fill(child: ColoredBox(color: t.imageScrim)),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    40,
                    VibraSpacing.pagePadding,
                    20,
                  ),
                  decoration: BoxDecoration(color: t.imageOverlay),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayEvent.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: t.onImage,
                            ),
                      ),
                      if (displayEvent.priceMin != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: t.accentPrimary,
                            borderRadius: VibraSpacing.borderSmall,
                            border: Border.all(color: t.onAccent),
                          ),
                          child: Text(
                            displayEvent.priceMax != null &&
                                    displayEvent.priceMax !=
                                        displayEvent.priceMin
                                ? '${_formattedPrice(context, displayEvent.priceMin!)} – ${_formattedPrice(context, displayEvent.priceMax!)}'
                                : _formattedPrice(
                                    context,
                                    displayEvent.priceMin!,
                                  ),
                            style: TextStyle(
                              color: t.onAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        [
                          if (eventPlaceLabel(displayEvent).isNotEmpty)
                            eventPlaceLabel(displayEvent),
                          DateFormat.yMMMd(
                            Localizations.localeOf(context).toString(),
                          ).format(displayEvent.eventDate.toLocal()),
                        ].join(' · '),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: t.onImageMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 12,
                child: IconButton.filledTonal(
                  tooltip: AppLocalizations.of(context)!.eventBackToEvents,
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/explore');
                    }
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
          if (displayEvent.priceMin != null || displayEvent.priceMax != null)
            Padding(
                  padding: EdgeInsets.all(VibraSpacing.pagePadding),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoPill(
                        label: AppLocalizations.of(context)!.eventPrice,
                        value:
                            (displayEvent.priceMin != null &&
                                displayEvent.priceMax != null)
                            ? (displayEvent.priceMin == displayEvent.priceMax
                                  ? _formattedPrice(
                                      context,
                                      displayEvent.priceMin!,
                                    )
                                  : '${_formattedPrice(context, displayEvent.priceMin!)} – ${_formattedPrice(context, displayEvent.priceMax!)}')
                            : _formattedPrice(
                                context,
                                (displayEvent.priceMin ??
                                    displayEvent.priceMax)!,
                              ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(begin: 0.05, end: 0),
          if (_cleanDescription(displayEvent.description ?? '').isNotEmpty)
            Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: VibraSpacing.pagePadding,
                  ),
                  child: _TranslatedDescription(
                    text: _cleanDescription(displayEvent.description ?? ''),
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.05, end: 0),
          const SizedBox(height: 20),
          VibraSectionHeader(
            title: AppLocalizations.of(context)!.eventDetailMapTitle,
            subtitle: AppLocalizations.of(context)!.eventDetailMapSub,
          ),
          if (coordinates != null)
            Container(
                  height: 180,
                  margin: EdgeInsets.fromLTRB(
                    VibraSpacing.pagePadding,
                    8,
                    VibraSpacing.pagePadding,
                    12,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: VibraSpacing.borderMedium,
                    border: Border.all(color: t.borderStrong),
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
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: t.accentPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(color: t.onAccent),
                                boxShadow: [t.cardShadow],
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: t.onAccent,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const VibraOpenStreetMapAttribution(),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 450.ms)
                .scaleXY(begin: 0.98, end: 1.0),
          if (coordinates == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text(
                l10n.eventLocationUnknown,
                style: TextStyle(color: t.textSecondary),
              ),
            ),
          if (eventDirectionsUri(displayEvent) != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: OutlinedButton.icon(
                onPressed: () => _openDirections(displayEvent),
                icon: const Icon(Icons.directions_rounded),
                label: Text(l10n.eventDirections),
              ),
            ),
          if (users.isNotEmpty)
            VibraSectionHeader(
              title: l10n.socialDiscoverUsers,
              subtitle: AppConstants.spotifyEnabled
                  ? l10n.socialHighCompatibility
                  : l10n.launchCommunitySubtitle,
            ),
          ...users.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            return VibraUserMatchCard(
                  user: user,
                  onTap: () =>
                      context.push('/user-profile', extra: user.user.id),
                  trailing: FilledButton.tonal(
                    onPressed: () => context.push(
                      '/chat',
                      extra: {
                        'otherUserId': user.user.id,
                        'otherDisplayName':
                            user.user.displayName ?? user.user.username,
                      },
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: t.accentPrimary,
                      foregroundColor: t.onAccent,
                    ),
                    child: Text(l10n.eventDetailChat),
                  ),
                )
                .animate()
                .fadeIn(delay: (400 + index * 100).ms, duration: 400.ms)
                .slideY(begin: 0.05, end: 0);
          }),
          Padding(
            padding: EdgeInsets.all(VibraSpacing.pagePadding),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.accentPrimary,
                      foregroundColor: t.onAccent,
                      elevation: 0,
                    ),
                    onPressed: _openingTickets
                        ? null
                        : () => _openTickets(displayEvent),
                    child: _openingTickets
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: VibraSpacing.pagePadding),
            child: Row(
              children: [
                _attendanceButton(
                  displayEvent,
                  l10n.eventDetailAttend,
                  'going',
                ),
                const SizedBox(width: 6),
                _attendanceButton(displayEvent, l10n.eventDetailMaybe, 'maybe'),
                const SizedBox(width: 6),
                _attendanceButton(
                  displayEvent,
                  l10n.eventDetailNotGoing,
                  'not_going',
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: l10n.eventCopyDetails,
                  onPressed: () => _copyDetails(displayEvent),
                  icon: const Icon(Icons.share_rounded, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _cleanDescription(String text) {
    if (text.isEmpty) return '';
    // Rimuove eventuali tag genere come "[Genre / Subgenre]" all'inizio
    final RegExp exp = RegExp(r'^\[.*?\]\s*\n*');
    return text.replaceAll(exp, '').trim();
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.vibraTokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: VibraSpacing.pagePadding,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: VibraSpacing.borderMedium,
        border: Border.all(color: t.borderDefault),
        boxShadow: [t.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: t.accentPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(color: t.textPrimary),
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
      style: theme.textTheme.bodyLarge?.copyWith(color: t.textPrimary),
    );
  }
}

String _formattedPrice(BuildContext context, double value) =>
    NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
      name: 'EUR',
    ).format(value);
