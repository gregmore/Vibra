import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/support_service.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../widgets/common/vibra_page_scaffold.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key, this.initialDescription});
  final String? initialDescription;

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  late final TextEditingController _description;
  final _service = SupportService(Supabase.instance.client);
  Uint8List? _screenshot;
  String? _extension;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _description = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() {
      _screenshot = null;
      _extension = file.name.split('.').last.toLowerCase();
    });
    final bytes = await file.readAsBytes();
    if (mounted) setState(() => _screenshot = bytes);
  }

  Future<void> _send() async {
    if (_description.text.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Descrivi brevemente cosa è successo (almeno 8 caratteri).',
          ),
        ),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await _service.submit(
        description: _description.text,
        screenshotBytes: _screenshot,
        screenshotExtension: _extension,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Segnalazione inviata'),
          content: Text(
            'Grazie: il team riceverà la segnalazione e risponderà ${AppConstants.supportResponseSla}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Non siamo riusciti a inviare la segnalazione. Riprova o scrivi a support@vibra.app.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    return VibraPageScaffold(
      appBar: AppBar(title: const Text('Segnala un problema')),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Spiega cosa è successo. Invieremo automaticamente versione dell’app, sistema operativo, ultimo errore e log tecnici recenti anonimizzati.',
            style: TextStyle(color: t.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _description,
            minLines: 5,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Descrizione del problema',
              hintText: 'Cosa stavi facendo? Cosa ti aspettavi?',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _sending ? null : _pickScreenshot,
            icon: Icon(
              _screenshot == null
                  ? Icons.add_photo_alternate_outlined
                  : Icons.check_circle_outline,
            ),
            label: Text(
              _screenshot == null
                  ? 'Aggiungi screenshot (facoltativo)'
                  : 'Screenshot allegato',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Non allegare password, codici di accesso o dati di altre persone.',
            style: TextStyle(color: t.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(_sending ? 'Invio in corso…' : 'Invia segnalazione'),
          ),
          const SizedBox(height: 16),
          Text(
            'In alternativa: ${AppConstants.supportEmail}\nTempo di risposta previsto: ${AppConstants.supportResponseSla}.',
            style: TextStyle(color: t.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
