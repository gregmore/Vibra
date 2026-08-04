import 'dart:io';

void main() {
  final file = File('lib/presentation/screens/explore/explore_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add maxZoom and minZoom to MapOptions
  content = content.replaceAll(
    'initialZoom: 10.5,',
    'initialZoom: 10.5,\n                      maxZoom: 18.0,\n                      minZoom: 3.0,',
  );

  // 2. Improve cluster marker builder
  final oldClusterBuilder = '''
                          builder: (context, markers) {
                            return Container(
                              decoration: BoxDecoration(
                                color: VibraColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  markers.length.toString(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
''';

  final newClusterBuilder = '''
                          builder: (context, markers) {
                            return Container(
                              decoration: BoxDecoration(
                                color: VibraColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: VibraColors.primary.withOpacity(0.6),
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
''';
  content = content.replaceAll(oldClusterBuilder, newClusterBuilder);

  // 3. Add zoom buttons and position them
  // We need to insert a Positioned after `if (eventsAsync.isLoading) ...`

  final oldStackChildrenEnd = '''
                  if (eventsAsync.isLoading)
                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: VibraColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [VibraShadows.cardElevation],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: VibraColors.accent)),
                              const SizedBox(width: 10),
                              Text(l10n.exploreSearchingEvents, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ).animate().fadeIn(duration: 200.ms),
                      ),
                    ),
                ],
              ),
''';

  final newStackChildrenEnd = '''
                  if (eventsAsync.isLoading)
                    Positioned(
                      top: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: VibraColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [VibraShadows.cardElevation],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: VibraColors.accent)),
                              const SizedBox(width: 10),
                              Text(l10n.exploreSearchingEvents, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(_mapController.camera.center, (currentZoom + 1).clamp(3.0, 18.0));
                        }),
                        const SizedBox(height: 8),
                        _buildZoomButton(Icons.remove_rounded, () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(_mapController.camera.center, (currentZoom - 1).clamp(3.0, 18.0));
                        }),
                      ],
                    ),
                  ),
                ],
              ),
''';
  content = content.replaceAll(oldStackChildrenEnd, newStackChildrenEnd);

  file.writeAsStringSync(content);
}
