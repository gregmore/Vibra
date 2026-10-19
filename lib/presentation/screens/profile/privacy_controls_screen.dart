import '../../../core/constants/app_constants.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibra/l10n/app_localizations.dart';

import '../../../core/theme/vibra_theme_tokens.dart';
import '../../widgets/common/vibra_page_scaffold.dart';
import '../../providers/app_state_providers.dart';
import '../../providers/location_provider.dart';

/// Controls for optional processing and Article 15/20 access requests.
class PrivacyControlsScreen extends ConsumerStatefulWidget {
  const PrivacyControlsScreen({super.key});

  @override
  ConsumerState<PrivacyControlsScreen> createState() =>
      _PrivacyControlsScreenState();
}

class _PrivacyControlsScreenState extends ConsumerState<PrivacyControlsScreen> {
  final _client = Supabase.instance.client;
  bool _loading = true;
  bool _exporting = false;
  bool _saving = false;
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
      _spotifyMatching =
          AppConstants.spotifyEnabled &&
          (row?['spotify_matching'] as bool? ?? false);
      _productNotifications = row?['product_notifications'] as bool? ?? false;
      _marketing = row?['marketing_notifications'] as bool? ?? false;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('Authentication required');
    await _client.from('privacy_preferences').upsert({
      'user_id': user.id,
      'location_processing': _location,
      'spotify_matching': _spotifyMatching,
      'product_notifications': _productNotifications,
      'marketing_notifications': _marketing,
      'policy_version': '2026-08-27',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    ref.invalidate(userLocationProvider);
    ref.invalidate(matchedUsersProvider);
  }

  Future<void> _toggle(void Function(bool value) update, bool value) async {
    final previous = [
      _location,
      _spotifyMatching,
      _productNotifications,
      _marketing,
    ];
    setState(() {
      update(value);
      _saving = true;
    });
    try {
      await _save();
    } catch (_) {
      if (mounted) {
        setState(() {
          _location = previous[0];
          _spotifyMatching = previous[1];
          _productNotifications = previous[2];
          _marketing = previous[3];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.privacySaveError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
          title: Text(AppLocalizations.of(context)!.privacyExportTitle),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(child: SelectableText(json)),
          ),
          actions: [
            TextButton(
              onPressed: () => _saveExport(json),
              child: Text(AppLocalizations.of(context)!.privacySaveJSON),
            ),
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: json));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.privacyCopiedJSON,
                      ),
                    ),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.privacyCopyJSON),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.commonClose),
            ),
          ],
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.privacyExportError),
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
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.privacyExportSaved(file.path),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return VibraPageScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsPrivacyData),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  AppLocalizations.of(context)!.privacyIntro,
                  style: TextStyle(color: t.textSecondary),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _location,
                  onChanged: _saving
                      ? null
                      : (v) => _toggle((value) => _location = value, v),
                  title: Text(
                    AppLocalizations.of(context)!.privacyPreciseLocation,
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.privacyPreciseLocationBody,
                  ),
                ),
                if (AppConstants.spotifyEnabled)
                  SwitchListTile(
                    value: _spotifyMatching,
                    onChanged: _saving
                        ? null
                        : (v) =>
                              _toggle((value) => _spotifyMatching = value, v),
                    title: Text(
                      AppLocalizations.of(context)!.privacySpotifyMatching,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.privacySpotifyMatchingBody,
                    ),
                  ),
                SwitchListTile(
                  value: _productNotifications,
                  onChanged: _saving
                      ? null
                      : (v) => _toggle(
                          (value) => _productNotifications = value,
                          v,
                        ),
                  title: Text(
                    AppLocalizations.of(context)!.privacyServiceNotifications,
                  ),
                  subtitle: Text(
                    AppConstants.spotifyEnabled
                        ? AppLocalizations.of(
                            context,
                          )!.privacyServiceNotificationsBody
                        : '${AppLocalizations.of(context)!.navChat} · ${AppLocalizations.of(context)!.myProfileMyEvents}',
                  ),
                ),
                SwitchListTile(
                  value: _marketing,
                  onChanged: _saving
                      ? null
                      : (v) => _toggle((value) => _marketing = value, v),
                  title: Text(AppLocalizations.of(context)!.privacyMarketing),
                  subtitle: Text(
                    AppLocalizations.of(context)!.privacyMarketingBody,
                  ),
                ),
                const Divider(height: 32),
                ListTile(
                  leading: Icon(Icons.download_rounded, color: t.accentPrimary),
                  title: Text(
                    AppLocalizations.of(context)!.privacyExportAction,
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context)!.privacyExportBody,
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
                  AppLocalizations.of(context)!.privacyDeletionBody,
                  style: TextStyle(color: t.textSecondary),
                ),
              ],
            ),
    );
  }
}
