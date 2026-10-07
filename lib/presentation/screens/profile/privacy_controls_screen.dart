import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../widgets/common/vibra_page_scaffold.dart';

/// Controls for optional processing and Article 15/20 access requests.
class PrivacyControlsScreen extends StatefulWidget {
  const PrivacyControlsScreen({super.key});

  @override
  State<PrivacyControlsScreen> createState() => _PrivacyControlsScreenState();
}

class _PrivacyControlsScreenState extends State<PrivacyControlsScreen> {
  final _client = Supabase.instance.client;
  bool _loading = true;
  bool _exporting = false;
  bool _location = false;
  bool _spotifyMatching = false;
  bool _productNotifications = false;
  bool _marketing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    Map<String, dynamic>? row;
    try {
      row = await _client
          .from('privacy_preferences')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
    } catch (error) {
      // The GDPR migration may not yet be deployed on an environment. Keep
      // the screen usable with safe defaults; saving will show a retry prompt.
      debugPrint('privacy_preferences non disponibile: $error');
    }
    if (!mounted) return;
    setState(() {
      _location = row?['location_processing'] as bool? ?? false;
      _spotifyMatching = row?['spotify_matching'] as bool? ?? false;
      _productNotifications = row?['product_notifications'] as bool? ?? false;
      _marketing = row?['marketing_notifications'] as bool? ?? false;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('privacy_preferences').upsert({
      'user_id': user.id,
      'location_processing': _location,
      'spotify_matching': _spotifyMatching,
      'product_notifications': _productNotifications,
      'marketing_notifications': _marketing,
      'policy_version': '2026-08-27',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> _toggle(void Function(bool value) update, bool value) async {
    setState(() => update(value));
    try {
      await _save();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossibile salvare la preferenza. Riprova.'),
          ),
        );
      }
    }
  }

  Future<void> _exportData() async {
    setState(() => _exporting = true);
    try {
      final data = await _client.rpc('export_my_personal_data');
      final json = const JsonEncoder.withIndent('  ').convert(data);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('La tua esportazione dati'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(child: SelectableText(json)),
          ),
          actions: [
            TextButton(
              onPressed: () => _saveExport(json),
              child: const Text('Salva JSON'),
            ),
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: json));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('JSON copiato negli appunti.'),
                    ),
                  );
                }
              },
              child: const Text('Copia JSON'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esportazione non disponibile. Riprova più tardi.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _saveExport(String json) async {
    final folder = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      ':',
      '-',
    );
    final file = File('${folder.path}/vibra-data-export-$timestamp.json');
    await file.writeAsString(json, flush: true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Esportazione salvata in ${file.path}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return VibraPageScaffold(
      appBar: AppBar(title: const Text('Privacy e dati personali')),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Scegli separatamente i trattamenti opzionali. Puoi cambiare idea in qualunque momento.',
                  style: TextStyle(color: t.textSecondary),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _location,
                  onChanged: (v) => _toggle((value) => _location = value, v),
                  title: const Text('Posizione precisa'),
                  subtitle: const Text(
                    'Per eventi vicini e funzionalità Live. Conservata al massimo 30 giorni.',
                  ),
                ),
                SwitchListTile(
                  value: _spotifyMatching,
                  onChanged: (v) =>
                      _toggle((value) => _spotifyMatching = value, v),
                  title: const Text('Spotify per matching'),
                  subtitle: const Text(
                    'Usa artisti, generi e ascolti sincronizzati per suggerimenti e affinità.',
                  ),
                ),
                SwitchListTile(
                  value: _productNotifications,
                  onChanged: (v) =>
                      _toggle((value) => _productNotifications = value, v),
                  title: const Text('Notifiche di servizio'),
                  subtitle: const Text('Match, messaggi ed eventi salvati.'),
                ),
                SwitchListTile(
                  value: _marketing,
                  onChanged: (v) => _toggle((value) => _marketing = value, v),
                  title: const Text('Comunicazioni marketing'),
                  subtitle: const Text(
                    'Sempre opzionali; non condizionano l’uso dell’app.',
                  ),
                ),
                const Divider(height: 32),
                ListTile(
                  leading: Icon(Icons.download_rounded, color: t.accentPrimary),
                  title: const Text('Esporta i miei dati'),
                  subtitle: const Text(
                    'Genera subito una copia JSON leggibile di profilo, chat, Spotify, eventi e interazioni.',
                  ),
                  trailing: _exporting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  onTap: _exporting ? null : _exportData,
                ),
                const SizedBox(height: 12),
                Text(
                  'Cancellazione account: i dati dell’account vengono eliminati; i messaggi inviati diventano anonimi e il loro contenuto/media viene rimosso. Le copie di backup seguono la retention operativa indicata nella privacy policy.',
                  style: TextStyle(color: t.textSecondary),
                ),
              ],
            ),
    );
  }
}
