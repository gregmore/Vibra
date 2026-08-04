import 'dart:io';

void main() {
  final file = File('lib/presentation/screens/explore/explore_screen.dart');
  var content = file.readAsStringSync();

  final buildMethod = '''
  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: VibraColors.surfaceElevated.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
''';

  if (!content.contains('_buildZoomButton')) {
    content = content.replaceAll(
      '  @override\n  Widget build(BuildContext context) {',
      buildMethod,
    );
    file.writeAsStringSync(content);
  }
}
