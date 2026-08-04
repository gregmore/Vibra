import 'dart:io';

void main() {
  final file = File('lib/presentation/screens/explore/explore_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add ValueKey to Marker
  content = content.replaceAll(
    'return Marker(\n                              point: LatLng(lat, lng),',
    'return Marker(\n                              key: ValueKey(e.id),\n                              point: LatLng(lat, lng),',
  );

  // 2. Add spiderfyCluster: false and onClusterTap
  final oldClusterOptions = 'MarkerClusterLayerOptions(';
  final newClusterOptions = '''MarkerClusterLayerOptions(
                          spiderfyCluster: false,
                          onClusterTap: (cluster) {
                            final currentZoom = _mapController.camera.zoom;
                            if (currentZoom >= 17.5) {
                              // We are at max zoom, show bottom sheet with events
                              final eventIds = cluster.markers
                                  .map((m) => (m.key as ValueKey<String>).value)
                                  .toSet();
                              final clusterEvents = filteredEvents
                                  .where((e) => eventIds.contains(e.id))
                                  .toList();
                                  
                              if (clusterEvents.isNotEmpty) {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: VibraColors.surface,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    return DraggableScrollableSheet(
                                      initialChildSize: 0.5,
                                      minChildSize: 0.3,
                                      maxChildSize: 0.9,
                                      expand: false,
                                      builder: (context, scrollController) {
                                        return Column(
                                          children: [
                                            const SizedBox(height: 12),
                                            Container(
                                              width: 40,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: VibraColors.textSecondary.withValues(alpha: 0.3),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              '\${clusterEvents.length} eventi in quest\\'area',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Expanded(
                                              child: ListView.builder(
                                                controller: scrollController,
                                                itemCount: clusterEvents.length,
                                                itemBuilder: (context, index) {
                                                  final event = clusterEvents[index];
                                                  return VibraEventCard(
                                                    event: event,
                                                    compact: true,
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      context.push('/event-detail', extra: event);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              }
                            }
                          },''';
                          
  content = content.replaceAll(oldClusterOptions, newClusterOptions);

  file.writeAsStringSync(content);
}
