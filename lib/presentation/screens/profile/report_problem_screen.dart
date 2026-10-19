import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/support_service.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/common/vibra_page_scaffold.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({
    super.key,
    this.initialDescription,
    this.supportService,
    this.imagePicker,
  });
  final String? initialDescription;
  final SupportService? supportService;
  final ImagePicker? imagePicker;

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  late final TextEditingController _description;
  late final SupportService _service;
  late final ImagePicker _picker;
  StreamSubscription<AuthState>? _authSubscription;
  Uint8List? _screenshot;
  bool _sending = false;
  bool _picking = false;
  int _draftGeneration = 0;
  String? _draftUser;

  @override
  void initState() {
    super.initState();
    _service =
        widget.supportService ?? SupportService(Supabase.instance.client);
    _picker = widget.imagePicker ?? ImagePicker();
    _draftUser = _service.currentUserId;
    _description = TextEditingController(text: widget.initialDescription);
    _authSubscription = _service.authStateChanges.listen((state) {
      if (!mounted) return;
      if (state.event == AuthChangeEvent.signedOut ||
          state.event == AuthChangeEvent.signedIn ||
          state.session?.user.id != _draftUser) {
        _draftGeneration++;
        _draftUser = state.session?.user.id;
        _description.clear();
        setState(() => _screenshot = null);
      }
    }, onError: (Object _, StackTrace _) {});
  }

  @override
  void dispose() {
    _draftGeneration++;
    unawaited(_authSubscription?.cancel());
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    if (_picking || _sending) return;
    final generation = _draftGeneration;
    final userId = _service.currentUserId;
    setState(() => _picking = true);
    try {
      if (userId == null) {
        throw const SupportSubmissionException(SupportFailure.authentication);
      }
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (!mounted ||
          generation != _draftGeneration ||
          file == null ||
          userId != _service.currentUserId) {
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted ||
          generation != _draftGeneration ||
          userId != _service.currentUserId) {
        return;
      }
      SupportService.validateScreenshot(bytes);
      setState(() => _screenshot = bytes);
    } on SupportSubmissionException catch (error) {
      if (mounted && generation == _draftGeneration) {
        _showFailure(error.failure);
      }
    } on PlatformException catch (error) {
      if (!mounted || generation != _draftGeneration) return;
      final l10n = AppLocalizations.of(context)!;
      final permissionDenied =
          error.code == 'photo_access_denied' ||
          error.code == 'photo_access_restricted';
      _showMessage(
        permissionDenied
            ? l10n.supportScreenshotPermissionDenied
            : l10n.supportScreenshotPickFailed,
      );
    } catch (_) {
      if (mounted && generation == _draftGeneration) {
        _showMessage(AppLocalizations.of(context)!.supportScreenshotPickFailed);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _send() async {
    if (_sending || _picking) return;
    try {
      SupportService.validateDescription(_description.text);
    } on SupportSubmissionException catch (error) {
      _showFailure(error.failure);
      return;
    }
    final generation = _draftGeneration;
    setState(() => _sending = true);
    try {
      await _service.submit(
        description: _description.text,
        screenshotBytes: _screenshot,
      );
      if (!mounted || generation != _draftGeneration) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.supportReportSentTitle),
          content: Text(AppLocalizations.of(context)!.supportReportSentBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.commonOK),
            ),
          ],
        ),
      );
      if (mounted && generation == _draftGeneration) {
        Navigator.pop(context);
      }
    } on SupportSubmissionException catch (error) {
      if (mounted && generation == _draftGeneration) {
        _showFailure(error.failure);
      }
    } catch (_) {
      if (mounted && generation == _draftGeneration) {
        _showFailure(SupportFailure.unavailable);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showFailure(SupportFailure failure) {
    final l10n = AppLocalizations.of(context)!;
    _showMessage(switch (failure) {
      SupportFailure.authentication => l10n.supportReportAuthRequired,
      SupportFailure.descriptionTooShort => l10n.supportDescriptionTooShort,
      SupportFailure.descriptionTooLong => l10n.supportDescriptionTooLong,
      SupportFailure.screenshotTooLarge => l10n.supportScreenshotTooLarge,
      SupportFailure.screenshotUnsupported => l10n.supportScreenshotUnsupported,
      SupportFailure.rateLimited => l10n.supportReportRateLimited,
      SupportFailure.unavailable => l10n.supportReportSendFailed(
        AppConstants.supportEmail,
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.supportReportTitle)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.supportReportIntro,
            style: TextStyle(color: t.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _description,
            enabled: !_sending,
            minLines: 5,
            maxLines: 8,
            maxLength: SupportService.maxDescriptionLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.supportDescriptionLabel,
              hintText: l10n.supportDescriptionHint,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _sending || _picking ? null : _pickScreenshot,
            icon: Icon(
              _screenshot == null
                  ? Icons.add_photo_alternate_outlined
                  : Icons.check_circle_outline,
            ),
            label: Text(
              _screenshot == null
                  ? l10n.supportAddScreenshot
                  : l10n.supportScreenshotAttached,
            ),
          ),
          if (_screenshot != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _screenshot!,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            TextButton.icon(
              onPressed: _sending
                  ? null
                  : () => setState(() {
                      _draftGeneration++;
                      _screenshot = null;
                    }),
              icon: const Icon(Icons.close),
              label: Text(l10n.supportRemoveScreenshot),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            l10n.supportScreenshotPrivacy,
            style: TextStyle(color: t.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _sending || _picking ? null : _send,
            icon: _sending
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              _sending ? l10n.supportSending : l10n.supportSendReport,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.supportAlternativeContact(AppConstants.supportEmail),
            style: TextStyle(color: t.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
