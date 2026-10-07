import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Chiede un parere solo dopo che la persona ha avuto tempo di usare l'app.
class SupportFeedbackPrompt extends StatefulWidget {
  const SupportFeedbackPrompt({required this.child, super.key});
  final Widget child;

  @override
  State<SupportFeedbackPrompt> createState() => _SupportFeedbackPromptState();
}

class _SupportFeedbackPromptState extends State<SupportFeedbackPrompt> {
  static const _installedAt = 'feedback_installed_at';
  static const _lastPromptAt = 'feedback_last_prompt_at';
  static const _prompted = 'feedback_prompted';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
  }

  Future<void> _maybePrompt() async {
    if (Supabase.instance.client.auth.currentUser == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final installed =
        DateTime.tryParse(prefs.getString(_installedAt) ?? '') ?? now;
    await prefs.setString(_installedAt, installed.toIso8601String());
    final last = DateTime.tryParse(prefs.getString(_lastPromptAt) ?? '');
    // Mai al primo avvio: almeno 7 giorni e non più di una volta ogni 90.
    if (!mounted ||
        prefs.getBool(_prompted) == true ||
        now.difference(installed).inDays < 7 ||
        (last != null && now.difference(last).inDays < 90)) {
      return;
    }
    await prefs.setString(_lastPromptAt, now.toIso8601String());
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Come sta andando con Vibra?'),
        content: const Text('Il tuo parere ci aiuta a migliorare.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push('/report-problem', extra: 'Feedback: ');
            },
            child: const Text('Non bene'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Così così'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await prefs.setBool(_prompted, true);
              final review = InAppReview.instance;
              if (await review.isAvailable()) await review.requestReview();
            },
            child: const Text('Bene!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
