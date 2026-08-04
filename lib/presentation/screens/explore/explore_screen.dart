import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../../../core/theme/vibra_colors.dart';
import '../../../core/theme/vibra_shadows.dart';
import '../../../core/theme/vibra_spacing.dart';
import '../../../domain/entities/event.dart';
import '../../providers/location_provider.dart';
import '../../providers/map_events_provider.dart';
import '../../widgets/common/vibra_event_card.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_section_header.dart';
import '../../widgets/common/vibra_state_views.dart';
import '../../widgets/vibra_category_filter.dart';
import '../../widgets/vibra_neon_map_pin.dart';
import '../../widgets/vibra_radar_pulse.dart';
import 'package:vibra/l10n/app_localizations.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const ExploreScreen({super.key, this.initialQuery});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _mapController = MapController();
  bool _showSearchAreaButton = false;
  String _searchQuery = '';
  int selectedRadius = 25;
  String selectedGenre = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedGenre.isEmpty) {
        setState(
          () => selectedGenre = AppLocalizations.of(context)!.exploreGenreAll,
        );
      }
      final locAsync = ref.read(userLocationProvider);
      if (locAsync.hasValue && locAsync.value != null) {
        if (widget.initialQuery != null &&
            widget.initialQuery!.trim().isNotEmpty) {
          _searchController.text = widget.initialQuery!;
          _searchQuery = widget.initialQuery!;
          _handleSearchSubmit(widget.initialQuery!);
        } else {
          _triggerMapSearch(
            locAsync.value!.latitude,
            locAsync.value!.longitude,
          );
        }
      } else {
        if (widget.initialQuery != null &&
            widget.initialQuery!.trim().isNotEmpty) {
          _searchController.text = widget.initialQuery!;
          _searchQuery = widget.initialQuery!;
          _handleSearchSubmit(widget.initialQuery!);
        } else {
          _triggerMapSearch(45.4642, 9.1900);
        }
      }
    });
  }

  void _triggerMapSearch(double lat, double lon) {
    ref
        .read(mapEventsProvider.notifier)
        .updateLocation(lat, lon, selectedRadius.toDouble() * 1000);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _handleSearchSubmit(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchQuery = '');
      return;
    }

    setState(() => _searchQuery = query.trim());

    try {
      final locations = await geo.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _mapController.move(LatLng(loc.latitude, loc.longitude), 12.0);
        _triggerMapSearch(loc.latitude, loc.longitude);
        setState(() => _searchQuery = '');
      }
    } catch (e) {
      // Se non trova la città, non mostriamo un errore.
    }
  }

  bool _matchesGenre(Event event, String genre, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (genre == l10n.exploreGenreAll) return true;

    final nameLower = event.name.toLowerCase();
    final artistLower = (event.artistName ?? '').toLowerCase();
    final descLower = (event.description ?? '').toLowerCase();
    final target = genre.toLowerCase();

    bool matchesAny(List<String> keywords) {
      for (final k in keywords) {
        if (nameLower.contains(k) ||
            artistLower.contains(k) ||
            descLower.contains(k)) {
          return true;
        }
      }
      return false;
    }

    if (target == 'electronic') {
      return matchesAny([
        'electronic',
        'elettronica',
        'electro',
        'techno',
        'dance',
        'house',
        'edm',
        'dj',
        'fred again',
        'the blaze',
        'bicep',
        'overmono',
        'électro',
      ]);
    }
    if (target == 'house') {
      return matchesAny(['house', 'club', 'dj', 'fred again', 'bicep']);
    }
    if (target == 'indie') {
      return matchesAny([
        'indie',
        'alternative',
        'rock',
        'psichedelico',
        'tame impala',
      ]);
    }
    if (target == 'rap') {
      return matchesAny([
        'rap',
        'hip hop',
        'hip-hop',
        'trap',
        'urban',
        'r&b',
        'mace',
      ]);
    }
    if (target == 'alternative') {
      return matchesAny(['alternative', 'alt', 'indie', 'mace', 'tame impala']);
    }

    return matchesAny([target]);
  }

  Color _getEventColor(Event event, BuildContext context) {
    final artistLower = (event.artistName ?? '').toLowerCase();
    final descLower = (event.description ?? '').toLowerCase();

    if (artistLower.contains('fred again') ||
        artistLower.contains('the blaze') ||
        descLower.contains('electronic')) {
      return Colors.cyanAccent;
    }
    if (descLower.contains('indie') || artistLower.contains('tame impala')) {
      return Colors.amberAccent;
    }
    if (descLower.contains('house') || descLower.contains('club')) {
      return Colors.orangeAccent;
    }
    if (descLower.contains('rap') || artistLower.contains('mace')) {
      return Colors.pinkAccent;
    }

    return VibraColors.primary;
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: VibraColors.surfaceElevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: VibraColors.glassBorder, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Icon(icon, size: 20, color: VibraColors.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locationAsync = ref.watch(userLocationProvider);
    final center = locationAsync.when(
      data: (loc) => LatLng(loc.latitude, loc.longitude),
      loading: () => const LatLng(45.4642, 9.1900),
      error: (_, stack) => const LatLng(45.4642, 9.1900),
    );

    final eventsAsync = ref.watch(mapEventsProvider);
    final events = eventsAsync.valueOrNull ?? [];

    final radii = const [25, 50, 100, 250];
    final genres = [
      l10n.exploreGenreAll,
      'Electronic',
      'Indie',
      'House',
      'Rap',
      'Alternative',
    ];

    final filteredEvents = events.where((e) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesText =
            e.name.toLowerCase().contains(query) ||
            (e.city ?? '').toLowerCase().contains(query) ||
            (e.venueName ?? '').toLowerCase().contains(query) ||
            (e.description ?? '').toLowerCase().contains(query);
        if (!matchesText) return false;
      }

      if (!_matchesGenre(e, selectedGenre, context)) return false;

      return true;
    }).toList();

    return VibraPageScaffold(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.exploreSearchEvents,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  });
                },
                onSubmitted: _handleSearchSubmit,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.exploreSearchHint,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: VibraColors.accent,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(
                      color: VibraColors.glassBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(
                      color: VibraColors.glassBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(
                      color: VibraColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: VibraSectionHeader(
              title: l10n.exploreInteractiveMap,
              subtitle: l10n.exploreLiveAroundYou,
            ),
          ),
          SliverToBoxAdapter(
            child:
                Container(
                      height: 290,
                      margin: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: VibraSpacing.borderLarge,
                        border: Border.all(
                          color: VibraColors.glassBorder,
                          width: 1,
                        ),
                        boxShadow: [VibraShadows.cardElevation],
                      ),
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: center,
                              initialZoom: 10.5,
                              maxZoom: 18.0,
                              minZoom: 3.0,
                              onPositionChanged: (position, hasGesture) {
                                if (hasGesture) {
                                  if (!_showSearchAreaButton) {
                                    setState(
                                      () => _showSearchAreaButton = true,
                                    );
                                  }
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                                userAgentPackageName: 'app.vibra.mobile',
                              ),
                              CircleLayer(
                                circles: [
                                  CircleMarker(
                                    point: center,
                                    radius: selectedRadius.toDouble() * 1000,
                                    useRadiusInMeter: true,
                                    color: VibraColors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderColor: VibraColors.primary.withValues(
                                      alpha: 0.6,
                                    ),
                                    borderStrokeWidth: 1.5,
                                  ),
                                ],
                              ),
                              MarkerClusterLayerWidget(
                                options: MarkerClusterLayerOptions(
                                  spiderfyCluster: true,
                                  showPolygon: false,
                                  maxClusterRadius: 40,
                                  size: const Size(40, 40),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(50),
                                  markers: filteredEvents.asMap().entries.map((
                                    entry,
                                  ) {
                                    final index = entry.key;
                                    final e = entry.value;
                                    final lat = e.latitude ?? 45.4642;
                                    final lng = e.longitude ?? 9.1900;
                                    final pinColor = _getEventColor(e, context);
                                    return Marker(
                                      key: ValueKey('${e.id}_$index'),
                                      point: LatLng(lat, lng),
                                      width: 48,
                                      height: 48,
                                      child: GestureDetector(
                                        onTap: () => context.push(
                                          '/event-detail',
                                          extra: e,
                                        ),
                                        child: VibraRadarPulse(
                                          size: 52,
                                          color: pinColor,
                                          child: VibraNeonMapPin(
                                            icon: Icons.music_note_rounded,
                                            color: pinColor,
                                            isSelected: true,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  builder: (context, markers) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: VibraColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: VibraColors.primary
                                                .withValues(alpha: 0.6),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          markers.length.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          if (_showSearchAreaButton)
                            Positioned(
                              top: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child:
                                    ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                VibraColors.surfaceElevated,
                                            foregroundColor:
                                                VibraColors.textPrimary,
                                            elevation: 4,
                                          ),
                                          icon: const Icon(
                                            Icons.search_rounded,
                                            size: 18,
                                          ),
                                          label: Text(l10n.exploreSearchInArea),
                                          onPressed: () {
                                            setState(
                                              () =>
                                                  _showSearchAreaButton = false,
                                            );
                                            _triggerMapSearch(
                                              _mapController
                                                  .camera
                                                  .center
                                                  .latitude,
                                              _mapController
                                                  .camera
                                                  .center
                                                  .longitude,
                                            );
                                          },
                                        )
                                        .animate()
                                        .fadeIn(duration: 200.ms)
                                        .slideY(begin: -0.2, end: 0),
                              ),
                            ),
                          if (eventsAsync.isLoading)
                            Positioned(
                              top: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: VibraColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [VibraShadows.cardElevation],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: VibraColors.accent,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        l10n.exploreSearchingEvents,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 200.ms),
                              ),
                            ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildZoomButton(Icons.add_rounded, () {
                                  final currentZoom =
                                      _mapController.camera.zoom;
                                  _mapController.move(
                                    _mapController.camera.center,
                                    (currentZoom + 1).clamp(3.0, 18.0),
                                  );

                                  final radii = const [25, 50, 100, 250];
                                  final currentIndex = radii.indexOf(
                                    selectedRadius,
                                  );
                                  if (currentIndex > 0) {
                                    setState(
                                      () => selectedRadius =
                                          radii[currentIndex - 1],
                                    );
                                    _triggerMapSearch(
                                      _mapController.camera.center.latitude,
                                      _mapController.camera.center.longitude,
                                    );
                                  }
                                }),
                                const SizedBox(height: 8),
                                _buildZoomButton(Icons.remove_rounded, () {
                                  final currentZoom =
                                      _mapController.camera.zoom;
                                  _mapController.move(
                                    _mapController.camera.center,
                                    (currentZoom - 1).clamp(3.0, 18.0),
                                  );

                                  final radii = const [25, 50, 100, 250];
                                  final currentIndex = radii.indexOf(
                                    selectedRadius,
                                  );
                                  if (currentIndex < radii.length - 1) {
                                    setState(
                                      () => selectedRadius =
                                          radii[currentIndex + 1],
                                    );
                                    _triggerMapSearch(
                                      _mapController.camera.center.latitude,
                                      _mapController.camera.center.longitude,
                                    );
                                  }
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scaleXY(begin: 0.96, end: 1.0, curve: Curves.easeOutBack),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.near_me_rounded,
                    size: 16,
                    color: VibraColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.exploreSearchRadius,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: radii
                    .map(
                      (radius) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(l10n.exploreRadius(radius.toString())),
                          selected: selectedRadius == radius,
                          onSelected: (_) {
                            setState(() => selectedRadius = radius);

                            double targetZoom = 10.5;
                            if (radius <= 25) {
                              targetZoom = 10.5;
                            } else if (radius <= 50) {
                              targetZoom = 9.5;
                            } else if (radius <= 100) {
                              targetZoom = 8.5;
                            } else {
                              targetZoom = 7.0;
                            }

                            _mapController.move(
                              _mapController.camera.center,
                              targetZoom,
                            );

                            _triggerMapSearch(
                              _mapController.camera.center.latitude,
                              _mapController.camera.center.longitude,
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.graphic_eq_rounded,
                    size: 16,
                    color: VibraColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.exploreMusicGenre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: VibraCategoryFilter(
              categories: genres,
              selectedCategory: selectedGenre,
              onSelected: (genre) => setState(() => selectedGenre = genre),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 18)),
          if (filteredEvents.isEmpty && !eventsAsync.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: VibraEmptyView(
                  title: l10n.socialMatchEmptyTitle,
                  message: _searchQuery.isNotEmpty
                      ? 'Premi Cerca sulla tastiera per cercare "$_searchQuery" nel mondo, oppure prova con un altro nome.'
                      : 'Proviamo ad ampliare il raggio di ricerca o a resettare i filtri.',
                  icon: Icons.radar_rounded,
                  actionLabel: AppLocalizations.of(
                    context,
                  )!.exploreShowAllEvents,
                  onActionTap: () {
                    setState(() {
                      selectedGenre = l10n.exploreGenreAll;
                      selectedRadius = 100;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                    _triggerMapSearch(center.latitude, center.longitude);
                  },
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                return VibraEventCard(
                  event: filteredEvents[index],
                  compact: true,
                  onTap: () => context.push(
                    '/event-detail',
                    extra: filteredEvents[index],
                  ),
                ).animate().slideY(
                  begin: 0.08,
                  end: 0,
                  curve: Curves.easeOutQuad,
                );
              },
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 160)),
        ],
      ),
    );
  }
}
