import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/vibra_spacing.dart';
import '../../../core/theme/vibra_text_styles.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../core/utils/geography.dart';
import '../../../domain/entities/event.dart';
import '../../providers/location_provider.dart';
import '../../providers/map_events_provider.dart';
import '../../widgets/common/vibra_button.dart';
import '../../widgets/common/vibra_editorial_event.dart';
import '../../widgets/common/vibra_input.dart';
import '../../widgets/common/vibra_openstreetmap_layer.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../widgets/common/vibra_surface.dart';
import '../../widgets/vibra_map_beacon.dart';
import '../../widgets/common/vibra_state_views.dart';
import 'package:vibra/l10n/app_localizations.dart';

final exploreGeocoderProvider =
    Provider<Future<List<geo.Location>> Function(String)>(
      (ref) =>
          (query) => geo.locationFromAddress(query),
    );

/// Eventi e mappa come un unico spazio fisico, non una lista con una mini-mappa.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _mapController = MapController();
  LatLng? _lastSearchCenter;
  int? _lastSearchRadiusKm;
  String _searchQuery = '';
  int selectedRadius = 25;
  int? _activeRadiusPreset;
  double _lastZoom = 10.5;
  int _selectedGenreIndex = 0;
  Timer? _debounce;
  int _searchRevision = 0;
  bool _mapReady = false;
  bool _hasMapInteraction = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(userLocationProvider, (previous, next) {
      final point = next.valueOrNull;
      if (!_mapReady ||
          !mounted ||
          _hasMapInteraction ||
          point == null ||
          !areValidCoordinates(point.latitude, point.longitude) ||
          widget.initialQuery?.trim().isNotEmpty == true) {
        return;
      }
      _mapController.move(LatLng(point.latitude, point.longitude), _lastZoom);
      _triggerMapSearch();
    });
  }

  void _onMapReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _mapReady) return;
      _mapReady = true;
      final point = ref.read(userLocationProvider).valueOrNull;
      if (point != null) {
        if (areValidCoordinates(point.latitude, point.longitude)) {
          _mapController.move(
            LatLng(point.latitude, point.longitude),
            _lastZoom,
          );
        }
      }
      _triggerMapSearch();
      // An artist or venue query still needs local events when it cannot be
      // geocoded. Fetch the current map before attempting a place lookup.
      final initialQuery = widget.initialQuery?.trim() ?? '';
      if (initialQuery.isNotEmpty) {
        _searchController.text = initialQuery;
        unawaited(_handleSearchSubmit(initialQuery));
      }
    });
  }

  @override
  void didUpdateWidget(covariant ExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery && _mapReady) {
      final query = widget.initialQuery?.trim() ?? '';
      _searchController.text = query;
      unawaited(_handleSearchSubmit(query));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  double _visibleRadiusMeters(MapCamera camera) {
    const distance = Distance();
    final bounds = camera.visibleBounds;
    return math.max(
      distance(camera.center, bounds.northEast),
      distance(camera.center, bounds.southWest),
    );
  }

  int _visibleRadiusKm(MapCamera camera) =>
      math.max(1, (_visibleRadiusMeters(camera) / 1000).ceil());

  void _triggerMapSearch() {
    if (!_mapReady || !mounted) return;
    final camera = _mapController.camera;
    // The database RPC accepts at most 250 km, even when the map is zoomed out.
    final radius = _visibleRadiusKm(camera).clamp(1, 250);
    if (selectedRadius != radius) setState(() => selectedRadius = radius);
    _lastSearchCenter = camera.center;
    _lastSearchRadiusKm = radius;
    ref
        .read(mapEventsProvider.notifier)
        .updateLocation(
          camera.center.latitude,
          (camera.center.longitude + 180) % 360 - 180,
          radius.toDouble() * 1000,
        );
  }

  /// A pan refreshes the area once the view has moved by more than 15% of
  /// its radius: enough to reveal new events, few enough requests to stay
  /// well inside the provider and per-user rate limits. The provider also
  /// debounces (500 ms) so a continuous drag issues a single request.
  bool _viewMovedEnough(MapCamera camera) {
    final last = _lastSearchCenter;
    final radiusKm = _lastSearchRadiusKm;
    if (last == null || radiusKm == null) return true;
    const distance = Distance();
    return distance(last, camera.center) > radiusKm * 1000 * 0.15;
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (!_mapReady || !mounted) return;
    if (hasGesture) {
      _hasMapInteraction = true;
      _searchRevision++;
    }
    if ((camera.zoom - _lastZoom).abs() > 0.001) {
      _lastZoom = camera.zoom;
      if (hasGesture && _activeRadiusPreset != null) {
        setState(() => _activeRadiusPreset = null);
      }
      _triggerMapSearch();
    } else if (hasGesture && _viewMovedEnough(camera)) {
      _triggerMapSearch();
    }
  }

  Future<void> _handleSearchSubmit(String query) async {
    _debounce?.cancel();
    final revision = ++_searchRevision;
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() => _searchQuery = '');
      return;
    }

    _hasMapInteraction = true;
    setState(() => _searchQuery = trimmed);
    try {
      final locations = await ref.read(exploreGeocoderProvider)(trimmed);
      if (!mounted || !_mapReady || revision != _searchRevision) return;
      if (locations.isEmpty) return;
      final location = locations.first;
      if (!areValidCoordinates(location.latitude, location.longitude)) return;
      _mapController.move(LatLng(location.latitude, location.longitude), 12);
      _triggerMapSearch();
      setState(() => _searchQuery = '');
    } catch (_) {
      // Il testo resta anche come filtro locale quando non è una località.
    }
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchRevision++;
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  bool _matchesGenre(Event event) {
    if (_selectedGenreIndex == 0) return true;

    final name = event.name.toLowerCase();
    final artist = (event.artistName ?? '').toLowerCase();
    final description = (event.description ?? '').toLowerCase();
    final target = const [
      'all',
      'electronic',
      'indie',
      'house',
      'rap',
      'alternative',
    ][_selectedGenreIndex];

    bool contains(List<String> keywords) => keywords.any(
      (keyword) =>
          name.contains(keyword) ||
          artist.contains(keyword) ||
          description.contains(keyword),
    );

    if (target == 'electronic') {
      return contains([
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
      return contains(['house', 'club', 'dj', 'fred again', 'bicep']);
    }
    if (target == 'indie') {
      return contains([
        'indie',
        'alternative',
        'rock',
        'psichedelico',
        'tame impala',
      ]);
    }
    if (target == 'rap') {
      return contains([
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
      return contains(['alternative', 'alt', 'indie', 'mace', 'tame impala']);
    }
    return contains([target]);
  }

  void _changeRadius(int radius) {
    _hasMapInteraction = true;
    _searchRevision++;
    final camera = _mapController.camera;
    // Scale using meters: rounding a close-up viewport to a whole kilometer
    // before calculating zoom can substantially undershoot the chosen radius.
    final visibleMeters = math.max(1.0, _visibleRadiusMeters(camera));
    final zoom =
        (camera.zoom + math.log(visibleMeters / (radius * 1000)) / math.ln2)
            .clamp(3.0, 18.0);
    _mapController.move(_mapController.camera.center, zoom);
    setState(() => _activeRadiusPreset = radius);
    _triggerMapSearch();
  }

  void _showEventsSheet(List<Event> events) {
    if (events.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EventsSheet(
        events: events,
        category: [
          AppLocalizations.of(context)!.exploreGenreAll,
          AppLocalizations.of(context)!.exploreGenreElectronic,
          'Indie',
          'House',
          'Rap',
          AppLocalizations.of(context)!.exploreGenreAlternative,
        ][_selectedGenreIndex],
        onEventTap: (event) {
          Navigator.of(sheetContext).pop();
          context.push('/event-detail', extra: event);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final t = context.vibraTokens;
    final location = ref.watch(userLocationProvider);
    final center = location.when(
      data: (value) => areValidCoordinates(value.latitude, value.longitude)
          ? LatLng(value.latitude, value.longitude)
          : const LatLng(45.4642, 9.1900),
      loading: () => const LatLng(45.4642, 9.1900),
      error: (_, _) => const LatLng(45.4642, 9.1900),
    );
    final eventsAsync = ref.watch(mapEventsProvider);
    final events = eventsAsync.valueOrNull ?? const <Event>[];
    final genres = [
      l10n.exploreGenreAll,
      l10n.exploreGenreElectronic,
      'Indie',
      'House',
      'Rap',
      l10n.exploreGenreAlternative,
    ];
    const radii = [25, 50, 100, 250];
    final filteredEvents = events.where((event) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesText =
            event.name.toLowerCase().contains(query) ||
            (event.city ?? '').toLowerCase().contains(query) ||
            (event.venueName ?? '').toLowerCase().contains(query) ||
            (event.description ?? '').toLowerCase().contains(query);
        if (!matchesText) return false;
      }
      return _matchesGenre(event);
    }).toList();

    return VibraPageScaffold(
      // The map uses the whole window on tablets too.
      maxContentWidth: null,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.xl,
                VibraSpacing.pagePadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.exploreEyebrow,
                    style: VibraTextStyles.labelSmall.copyWith(
                      color: t.accentPrimary,
                    ),
                  ),
                  const SizedBox(height: VibraSpacing.sm),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.exploreSearchEvents,
                      style: VibraTextStyles.headlineLarge.copyWith(
                        color: t.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: VibraSpacing.lg),
                  VibraInput(
                    controller: _searchController,
                    hintText: l10n.exploreSearchHint,
                    prefixIcon: Icons.search_rounded,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      _searchRevision++;
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 280), () {
                        if (mounted) {
                          setState(() => _searchQuery = value.trim());
                        }
                      });
                    },
                    onSubmitted: _handleSearchSubmit,
                    suffix: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.exploreClearSearch,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: _clearSearch,
                          ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.lg,
                VibraSpacing.pagePadding,
                0,
              ),
              child: _MapCanvas(
                center: center,
                controller: _mapController,
                events: filteredEvents,
                isLoading: eventsAsync.isLoading,
                // Fallback when an automatic refresh failed (e.g. offline or
                // rate limited): one tap retries the current view.
                showSearchArea: eventsAsync.hasError && _hasMapInteraction,
                searchAreaLabel: l10n.exploreSearchInArea,
                onMapMoved: _onMapPositionChanged,
                onMapReady: _onMapReady,
                onSearchArea: () {
                  _searchRevision++;
                  _lastSearchCenter = null;
                  _triggerMapSearch();
                  ref.read(mapEventsProvider.notifier).refresh();
                },
                onZoomIn: () {
                  _hasMapInteraction = true;
                  _searchRevision++;
                  _activeRadiusPreset = null;
                  _mapController.move(
                    _mapController.camera.center,
                    (_mapController.camera.zoom + 1).clamp(3.0, 18.0),
                  );
                },
                onZoomOut: () {
                  _hasMapInteraction = true;
                  _searchRevision++;
                  _activeRadiusPreset = null;
                  _mapController.move(
                    _mapController.camera.center,
                    (_mapController.camera.zoom - 1).clamp(3.0, 18.0),
                  );
                },
                onEventsTap: () => _showEventsSheet(filteredEvents),
                onEventTap: (event) =>
                    context.push('/event-detail', extra: event),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.xxl,
                VibraSpacing.pagePadding,
                VibraSpacing.sm,
              ),
              child: _FilterLabel(
                icon: Icons.radar_rounded,
                label: l10n.exploreSearchRadius(selectedRadius),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _FilterRail(
              items: radii.map((radius) => '$radius km').toList(),
              selectedIndex: radii.indexOf(
                _activeRadiusPreset ?? selectedRadius,
              ),
              onSelected: (index) => _changeRadius(radii[index]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.lg,
                VibraSpacing.pagePadding,
                VibraSpacing.sm,
              ),
              child: _FilterLabel(
                icon: Icons.graphic_eq_rounded,
                label: l10n.exploreFilterByGenre.toUpperCase(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _FilterRail(
              items: genres,
              selectedIndex: _selectedGenreIndex,
              onSelected: (index) =>
                  setState(() => _selectedGenreIndex = index),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                VibraSpacing.sectionGap,
                VibraSpacing.sm,
                VibraSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.exploreEventsVisible(filteredEvents.length),
                      style: VibraTextStyles.titleMedium.copyWith(
                        color: t.textPrimary,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: _clearSearch,
                      child: Text(l10n.commonReset),
                    ),
                ],
              ),
            ),
          ),
          if (eventsAsync.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  0,
                  VibraSpacing.pagePadding,
                  VibraSpacing.navBarClearance,
                ),
                child: VibraErrorView(
                  error: eventsAsync.error,
                  compact: true,
                  kind: VibraErrorKind.network,
                  title: l10n.exploreLoadErrorTitle,
                  message: l10n.exploreLoadErrorBody,
                  onRetry: () => ref.read(mapEventsProvider.notifier).refresh(),
                ),
              ),
            )
          else if (filteredEvents.isEmpty && !eventsAsync.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VibraSpacing.pagePadding,
                  0,
                  VibraSpacing.pagePadding,
                  VibraSpacing.navBarClearance,
                ),
                child: VibraEmptyView(
                  compact: true,
                  icon: _searchQuery.isNotEmpty
                      ? Icons.search_off_rounded
                      : Icons.map_outlined,
                  title: l10n.exploreEmptyTitle,
                  message: l10n.exploreEmptyBody,
                  actionLabel: l10n.exploreShowAllEvents,
                  onActionTap: () {
                    setState(() => _selectedGenreIndex = 0);
                    _clearSearch();
                    _changeRadius(100);
                  },
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                VibraSpacing.pagePadding,
                0,
                VibraSpacing.pagePadding,
                VibraSpacing.navBarClearance,
              ),
              sliver: SliverList.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) => VibraEventRow(
                  event: filteredEvents[index],
                  onTap: () => context.push(
                    '/event-detail',
                    extra: filteredEvents[index],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({
    required this.center,
    required this.controller,
    required this.events,
    required this.isLoading,
    required this.showSearchArea,
    required this.searchAreaLabel,
    required this.onMapMoved,
    required this.onMapReady,
    required this.onSearchArea,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onEventsTap,
    required this.onEventTap,
  });

  final LatLng center;
  final MapController controller;
  final List<Event> events;
  final bool isLoading;
  final bool showSearchArea;
  final String searchAreaLabel;
  final void Function(MapCamera, bool) onMapMoved;
  final VoidCallback onMapReady;
  final VoidCallback onSearchArea;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onEventsTap;
  final ValueChanged<Event> onEventTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final height = (MediaQuery.sizeOf(context).height * .52).clamp(
      380.0,
      500.0,
    );
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: VibraSpacing.borderXL,
        child: Stack(
          children: [
            FlutterMap(
              mapController: controller,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 10.5,
                maxZoom: 18,
                minZoom: 3,
                onPositionChanged: onMapMoved,
                onMapReady: onMapReady,
              ),
              children: [
                const VibraOpenStreetMapTileLayer(),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    spiderfyCluster: true,
                    showPolygon: false,
                    maxClusterRadius: 42,
                    markerChildBehavior: true,
                    size: const Size(46, 46),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(48),
                    markers: events
                        .asMap()
                        .entries
                        .where(
                          (entry) => areValidCoordinates(
                            entry.value.latitude,
                            entry.value.longitude,
                          ),
                        )
                        .map((entry) {
                          final index = entry.key;
                          final event = entry.value;
                          return Marker(
                            key: ValueKey(
                              '${event.source}:${event.externalId}:${event.id}',
                            ),
                            point: LatLng(event.latitude!, event.longitude!),
                            width: 58,
                            height: 58,
                            child: Semantics(
                              button: true,
                              label: l10n.eventOpenSemantics(
                                event.name,
                                DateFormat.yMMMd(
                                  l10n.localeName,
                                ).format(event.eventDate),
                                event.venueName ?? event.city ?? "",
                              ),
                              child: GestureDetector(
                                onTap: () => onEventTap(event),
                                child: VibraMapBeacon(selected: index == 0),
                              ),
                            ),
                          );
                        })
                        .toList(),
                    builder: (context, markers) => Container(
                      decoration: BoxDecoration(
                        color: t.backgroundPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.accentPrimary, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        markers.length.toString(),
                        style: VibraTextStyles.labelLarge.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const VibraOpenStreetMapAttribution(),
              ],
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: t.borderDefault, width: 1),
                    borderRadius: VibraSpacing.borderXL,
                  ),
                ),
              ),
            ),
            if (showSearchArea)
              Positioned(
                top: 14,
                left: 0,
                right: 0,
                child: Center(
                  child: VibraButton(
                    label: searchAreaLabel,
                    tone: VibraButtonTone.ink,
                    leadingIcon: Icons.refresh_rounded,
                    onPressed: onSearchArea,
                  ),
                ),
              ),
            if (isLoading)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(VibraSpacing.sm),
                  decoration: BoxDecoration(
                    color: t.backgroundPrimary.withValues(alpha: .92),
                    borderRadius: VibraSpacing.borderSmall,
                  ),
                  child: const VibraLoadingIndicator(size: 20, showMark: false),
                ),
              ),
            Positioned(
              right: 12,
              top: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: t.backgroundPrimary.withValues(alpha: .92),
                  borderRadius: VibraSpacing.borderMedium,
                  border: Border.all(color: t.borderDefault),
                ),
                child: Column(
                  children: [
                    _MapSquareButton(
                      icon: Icons.add_rounded,
                      label: l10n.exploreZoomIn,
                      onTap: onZoomIn,
                    ),
                    Container(width: 24, height: 1, color: t.borderDefault),
                    _MapSquareButton(
                      icon: Icons.remove_rounded,
                      label: l10n.exploreZoomOut,
                      onTap: onZoomOut,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 44,
              child: VibraSurface(
                color: t.backgroundPrimary.withValues(alpha: 0.94),
                borderColor: t.borderDefault,
                radius: VibraSpacing.radiusMedium,
                semanticLabel: events.isEmpty
                    ? null
                    : l10n.exploreOpenEvents(events.length),
                padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                onTap: events.isEmpty ? null : onEventsTap,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: events.isEmpty ? t.surfaceMuted : t.accentFill,
                        borderRadius: VibraSpacing.borderSmall,
                      ),
                      child: Text(
                        '${events.length}',
                        style: VibraTextStyles.labelMedium.copyWith(
                          color: events.isEmpty ? t.textSecondary : t.onAccent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: VibraSpacing.md),
                    Expanded(
                      child: Text(
                        events.isEmpty
                            ? l10n.exploreMoveMapHint
                            : l10n.exploreEventsInArea(events.length),
                        style: VibraTextStyles.labelLarge.copyWith(
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                    if (events.isNotEmpty)
                      Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: VibraSpacing.iconMd,
                        color: t.textSecondary,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsSheet extends StatelessWidget {
  const _EventsSheet({
    required this.events,
    required this.category,
    required this.onEventTap,
  });

  final List<Event> events;
  final String category;
  final ValueChanged<Event> onEventTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final allLabel = AppLocalizations.of(context)!.exploreGenreAll;
    final categoryLabel = category == allLabel
        ? l10n.exploreGenreAll
        : category;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) => Material(
        color: t.surfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VibraSpacing.radiusXL),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: t.borderStrong,
                borderRadius: VibraSpacing.borderFull,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryLabel.toUpperCase(),
                          style: VibraTextStyles.labelSmall.copyWith(
                            color: t.accentPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.exploreEventsInArea(events.length),
                          style: VibraTextStyles.headlineSmall.copyWith(
                            color: t.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.exploreCloseEvents,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: t.borderDefault),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: events.length,
                itemBuilder: (context, index) => VibraEventRow(
                  event: events[index],
                  onTap: () => onEventTap(events[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapSquareButton extends StatelessWidget {
  const _MapSquareButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: VibraSpacing.borderMedium,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: t.textPrimary, size: VibraSpacing.iconMd),
          ),
        ),
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Row(
      children: [
        Icon(icon, size: VibraSpacing.iconSm, color: t.textSecondary),
        const SizedBox(width: VibraSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: VibraTextStyles.labelSmall.copyWith(color: t.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _FilterRail extends StatelessWidget {
  const _FilterRail({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: VibraSpacing.pageHorizontal,
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: VibraSpacing.sm),
            child: ChoiceChip(
              label: Text(items[index]),
              selected: selected,
              onSelected: (_) => onSelected(index),
              showCheckmark: false,
              avatar: selected
                  ? Icon(
                      Icons.check_rounded,
                      size: VibraSpacing.iconSm,
                      color: t.accentPrimary,
                    )
                  : null,
              backgroundColor: t.surface,
              selectedColor: t.accentSoft,
              side: BorderSide(
                color: selected ? t.accentPrimary : t.borderDefault,
              ),
              labelStyle: VibraTextStyles.labelMedium.copyWith(
                color: selected ? t.textPrimary : t.textSecondary,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            ),
          );
        }),
      ),
    );
  }
}
