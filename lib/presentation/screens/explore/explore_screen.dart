import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../../widgets/vibra_signal_wave.dart';
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
  bool _showSearchAreaButton = false;
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
    ref
        .read(mapEventsProvider.notifier)
        .updateLocation(
          camera.center.latitude,
          (camera.center.longitude + 180) % 360 - 180,
          radius.toDouble() * 1000,
        );
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (!_mapReady || !mounted) return;
    if (hasGesture) {
      _hasMapInteraction = true;
      _searchRevision++;
    }
    if ((camera.zoom - _lastZoom).abs() > 0.001) {
      _lastZoom = camera.zoom;
      setState(() {
        _showSearchAreaButton = false;
        if (hasGesture) _activeRadiusPreset = null;
      });
      _triggerMapSearch();
    } else if (hasGesture && !_showSearchAreaButton) {
      setState(() => _showSearchAreaButton = true);
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
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.exploreEyebrow,
                    style: VibraTextStyles.labelSmall.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.exploreSearchEvents,
                    style: VibraTextStyles.displaySmall,
                  ),
                  const SizedBox(height: 18),
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
            ).animate().fadeIn(duration: 320.ms),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _MapCanvas(
                center: center,
                controller: _mapController,
                events: filteredEvents,
                isLoading: eventsAsync.isLoading,
                showSearchArea: _showSearchAreaButton,
                searchAreaLabel: l10n.exploreSearchInArea,
                onMapMoved: _onMapPositionChanged,
                onMapReady: _onMapReady,
                onSearchArea: () {
                  _searchRevision++;
                  setState(() => _showSearchAreaButton = false);
                  _triggerMapSearch();
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
            ).animate().fadeIn(delay: 80.ms, duration: 380.ms),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Text(
                l10n.exploreSearchRadius(selectedRadius),
                style: VibraTextStyles.labelSmall.copyWith(
                  color: t.textSecondary,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _FilterRail(
                items: radii.map((radius) => '$radius km').toList(),
                selectedIndex: radii.indexOf(
                  _activeRadiusPreset ?? selectedRadius,
                ),
                onSelected: (index) => _changeRadius(radii[index]),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _FilterRail(
                items: genres,
                selectedIndex: _selectedGenreIndex,
                onSelected: (index) =>
                    setState(() => _selectedGenreIndex = index),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.exploreEventsVisible(filteredEvents.length),
                      style: VibraTextStyles.labelSmall.copyWith(
                        color: t.textSecondary,
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 148),
                child: VibraSurface(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.exploreLoadErrorTitle,
                        style: VibraTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.exploreLoadErrorBody,
                        style: VibraTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      VibraButton(
                        label: l10n.commonRetry,
                        onPressed: () =>
                            ref.read(mapEventsProvider.notifier).refresh(),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (filteredEvents.isEmpty && !eventsAsync.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 148),
                child: VibraSurface(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: VibraSignalWave(
                          height: 34,
                          color: t.accentPrimary,
                          secondaryColor: t.textPrimary,
                          amplitude: 7,
                          animate: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.exploreEmptyTitle,
                        style: VibraTextStyles.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.exploreEmptyBody,
                        style: VibraTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 18),
                      VibraButton(
                        label: l10n.exploreShowAllEvents,
                        tone: VibraButtonTone.signal,
                        onPressed: () {
                          setState(() => _selectedGenreIndex = 0);
                          _clearSearch();
                          _changeRadius(100);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 148),
              sliver: SliverList.builder(
                itemCount: filteredEvents.length,
                itemBuilder: (context, index) =>
                    VibraEventRow(
                      event: filteredEvents[index],
                      onTap: () => context.push(
                        '/event-detail',
                        extra: filteredEvents[index],
                      ),
                      showDivider: index != filteredEvents.length - 1,
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: 45 * index),
                      duration: 260.ms,
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
    return SizedBox(
      height: 410,
      child: ClipRRect(
        borderRadius: VibraSpacing.borderMedium,
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
                    size: const Size(44, 44),
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
                            width: 60,
                            height: 60,
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
                        color: t.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.borderStrong),
                        boxShadow: [t.elevatedShadow],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        markers.length.toString(),
                        style: VibraTextStyles.labelLarge.copyWith(
                          color: t.textPrimary,
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
                    border: Border.all(color: t.borderStrong, width: 1),
                    borderRadius: VibraSpacing.borderMedium,
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
                top: 16,
                left: 16,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: t.accentPrimary,
                  ),
                ),
              ),
            Positioned(
              right: 12,
              top: 12,
              child: Column(
                children: [
                  _MapSquareButton(
                    icon: Icons.add_rounded,
                    label: l10n.exploreZoomIn,
                    onTap: onZoomIn,
                  ),
                  const SizedBox(height: 6),
                  _MapSquareButton(
                    icon: Icons.remove_rounded,
                    label: l10n.exploreZoomOut,
                    onTap: onZoomOut,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 44,
              child: VibraSurface(
                color: t.surfaceElevated.withValues(alpha: 0.96),
                semanticLabel: events.isEmpty
                    ? null
                    : l10n.exploreOpenEvents(events.length),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                onTap: events.isEmpty ? null : onEventsTap,
                child: Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: VibraSignalWave(
                        height: 16,
                        color: t.accentPrimary,
                        secondaryColor: t.accentSecondary,
                        amplitude: 3,
                        animate: events.isNotEmpty,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        events.isEmpty
                            ? l10n.exploreMoveMapHint
                            : l10n.exploreEventsInArea(events.length),
                        style: VibraTextStyles.labelLarge,
                      ),
                    ),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 18,
                      color: t.textPrimary,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(VibraSpacing.radiusXL),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
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
                            color: t.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.exploreEventsInArea(events.length),
                          style: VibraTextStyles.titleLarge,
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: events.length,
                itemBuilder: (context, index) => VibraEventRow(
                  event: events[index],
                  onTap: () => onEventTap(events[index]),
                  showDivider: index != events.length - 1,
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
        color: t.surfaceElevated,
        borderRadius: VibraSpacing.borderSmall,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: VibraSpacing.borderSmall,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: t.textPrimary, size: 20),
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(items[index]),
              selected: selected,
              onSelected: (_) => onSelected(index),
              showCheckmark: true,
              side: BorderSide(
                color: selected ? t.accentPrimary : t.borderStrong,
              ),
              labelStyle: VibraTextStyles.labelMedium.copyWith(
                color: selected ? t.accentPrimary : t.textSecondary,
              ),
            ),
          );
        }),
      ),
    );
  }
}
