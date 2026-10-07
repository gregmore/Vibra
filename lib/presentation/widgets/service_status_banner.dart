import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/vibra_theme_tokens.dart';

/// Mostra solo incidenti attivi pubblicati dal team, senza trasformare un
/// problema di un fornitore esterno in un errore apparentemente locale.
class ServiceStatusBanner extends StatefulWidget {
  const ServiceStatusBanner({required this.child, super.key});
  final Widget child;

  @override
  State<ServiceStatusBanner> createState() => _ServiceStatusBannerState();
}

class _ServiceStatusBannerState extends State<ServiceStatusBanner> {
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadIncident();
  }

  Future<void> _loadIncident() async {
    try {
      final incident = await Supabase.instance.client
          .from('service_incidents')
          .select('message')
          .eq('status', 'investigating')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (mounted) setState(() => _message = incident?['message'] as String?);
    } catch (_) {
      // Il banner è informativo: l'app resta utilizzabile se la query fallisce.
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return Column(
      children: [
        if (_message != null)
          Material(
            color: t.surfaceElevated,
            child: SafeArea(
              bottom: false,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: t.warning, width: 2),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.info_outline_rounded, color: t.warning),
                  title: Text(
                    _message!,
                    style: TextStyle(color: t.textPrimary),
                  ),
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
