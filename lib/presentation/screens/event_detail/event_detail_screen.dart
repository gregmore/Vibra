import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_shadows.dart';
import '../../../domain/entities/event.dart';
import '../../../domain/usecases/events_usecases.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/usecase_providers.dart';
import '../../providers/core_providers.dart';
import 'package:vibra/l10n/app_localizations.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/common/vibra_user_match_card.dart';

class EventDetailScreen extends ConsumerWidget {
  final Event? event;
  const EventDetailScreen({super.key, this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredEventsProvider);
    final displayEvent = event ?? (featured.isNotEmpty ? featured.first : null);
    final users = ref.watch(matchedUsersProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (displayEvent == null) {
      return VibraPageScaffold(
        child: VibraEmptyView(
          title: l10n.eventDetailNotAvailableTitle,
          message: l10n.eventDetailNotAvailableMsg,
          icon: Icons.event_busy_rounded,
        ),
      );
    }

    return VibraPageScaffold(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Stack(
            children: [
              SizedBox(
                height: 320,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: displayEvent.imageUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: VibraColors.shimmerBase,
                    highlightColor: VibraColors.shimmerHighlight,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) =>
                      Container(color: VibraColors.surface),
                ),
              ),
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        VibraColors.background.withValues(alpha: 0.8),
                        VibraColors.background,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayEvent.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                            color: VibraColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: VibraColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            displayEvent.priceMax != null &&
                                    displayEvent.priceMax !=
                                        displayEvent.priceMin
                                ? '€${displayEvent.priceMin!.toStringAsFixed(2)} - €${displayEvent.priceMax!.toStringAsFixed(2)}'
                                : '€${displayEvent.priceMin!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: VibraColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${displayEvent.venueName} · ${displayEvent.city} · ${displayEvent.eventDate.day}/${displayEvent.eventDate.month}/${displayEvent.eventDate.year}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
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
                  onPressed: () => context.pop(),
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
                        label: 'Prezzo',
                        value:
                            (displayEvent.priceMin != null &&
                                displayEvent.priceMax != null)
                            ? (displayEvent.priceMin == displayEvent.priceMax
                                  ? '${displayEvent.priceMin!.toStringAsFixed(0)}€'
                                  : '${displayEvent.priceMin!.toStringAsFixed(0)}€ - ${displayEvent.priceMax!.toStringAsFixed(0)}€')
                            : '${(displayEvent.priceMin ?? displayEvent.priceMax)!.toStringAsFixed(0)}€',
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
                  borderRadius: BorderRadius.circular(VibraSpacing.radiusLarge),
                  border: Border.all(
                    color: VibraColors.glassBorder,
                    width: 1.5,
                  ),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
                      displayEvent.latitude ?? 45.4642,
                      displayEvent.longitude ?? 9.1900,
                    ),
                    initialZoom: 14.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                      userAgentPackageName: 'app.vibra.mobile',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            displayEvent.latitude ?? 45.4642,
                            displayEvent.longitude ?? 9.1900,
                          ),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: VibraColors.accent,
                              shape: BoxShape.circle,
                              boxShadow: [VibraShadows.magentaGlow],
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 450.ms)
              .scaleXY(begin: 0.98, end: 1.0),
          VibraSectionHeader(
            title: AppLocalizations.of(context)!.eventDetailAttendeesTitle,
            subtitle: AppLocalizations.of(context)!.eventDetailAttendeesSub,
          ),
          ...users.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            return VibraUserMatchCard(
                  user: user,
                  onTap: () => context.push('/user-profile', extra: user),
                  trailing: FilledButton.tonal(
                    onPressed: () => context.push('/chat'),
                    style: FilledButton.styleFrom(
                      backgroundColor: VibraColors.accent,
                      foregroundColor: VibraColors.textPrimary,
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
                      backgroundColor: VibraColors.primary,
                      foregroundColor: VibraColors.textPrimary,
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final urlStr = displayEvent.ticketUrl;
                      if (urlStr == null ||
                          urlStr.trim().isEmpty ||
                          displayEvent.status == 'canceled' ||
                          displayEvent.status == 'offsale') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.eventDetailTicketsUnavailable),
                          ),
                        );
                        return;
                      }
                      final uri = Uri.tryParse(urlStr);
                      if (uri != null && await canLaunchUrl(uri)) {
                        try {
                          await ref
                              .read(supabaseDatasourceProvider)
                              .client
                              .functions
                              .invoke(
                                'track-ticket-click',
                                body: {'event_id': displayEvent.id},
                              );
                        } catch (e) {
                          debugPrint('Tracking error: $e');
                        }
                        await launchUrl(uri, mode: LaunchMode.inAppWebView);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.eventDetailTicketsError),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      displayEvent.status == 'canceled'
                          ? 'Cancellato'
                          : displayEvent.status == 'offsale'
                          ? 'Sold Out'
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
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                    ),
                    onPressed: () async {
                      try {
                        await ref
                            .read(setEventAttendanceUseCaseProvider)
                            .call(
                              SetEventAttendanceParams(
                                event: displayEvent,
                                status: 'going',
                              ),
                            );
                        ref.read(myEventsProvider.notifier).refresh();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.eventDetailAttendanceConfirmed,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.settingsError(e.toString())),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      l10n.eventDetailAttend,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                    ),
                    onPressed: () async {
                      try {
                        await ref
                            .read(setEventAttendanceUseCaseProvider)
                            .call(
                              SetEventAttendanceParams(
                                event: displayEvent,
                                status: 'maybe',
                              ),
                            );
                        ref.read(myEventsProvider.notifier).refresh();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.eventDetailAttendanceMaybe),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.settingsError(e.toString())),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      l10n.eventDetailMaybe,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                    ),
                    onPressed: () async {
                      try {
                        await ref
                            .read(setEventAttendanceUseCaseProvider)
                            .call(
                              SetEventAttendanceParams(
                                event: displayEvent,
                                status: 'not_going',
                              ),
                            );
                        ref.read(myEventsProvider.notifier).refresh();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.eventDetailAttendanceNotGoing),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.settingsError(e.toString())),
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      l10n.eventDetailNotGoing,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text:
                            '${displayEvent.name}\n'
                            '${displayEvent.venueName} · ${displayEvent.city}\n'
                            '${displayEvent.eventDate.day}/${displayEvent.eventDate.month}/${displayEvent.eventDate.year}\n'
                            'Ticket: ${displayEvent.ticketUrl ?? ''}',
                      ),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.eventDetailCopied)),
                      );
                    }
                  },
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: VibraSpacing.pagePadding,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: VibraColors.surfaceElevated,
        borderRadius: BorderRadius.circular(VibraSpacing.radiusMedium),
        border: Border.all(color: VibraColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: VibraColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: VibraColors.textPrimary,
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

    try {
      final translator = GoogleTranslator();
      final translation = await translator.translate(
        widget.text,
        to: _targetLang!,
      );
      if (mounted) {
        setState(() {
          _translatedText = translation.text;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
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

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(VibraColors.accent),
          ),
        ),
      );
    }

    return Text(
      _translatedText ?? widget.text,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: VibraColors.textPrimary,
      ),
    );
  }
}
