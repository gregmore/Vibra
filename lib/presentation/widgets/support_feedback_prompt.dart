import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';

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
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
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
    if (!mounted || Supabase.instance.client.auth.currentUser?.id != userId) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.supportFeedbackTitle),
        content: Text(l10n.supportFeedbackBody),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (!mounted ||
                  Supabase.instance.client.auth.currentUser?.id != userId) {
                return;
              }
              context.push(
                '/report-problem',
                extra: l10n.supportFeedbackDescriptionPrefix,
              );
            },
            child: Text(l10n.supportFeedbackNegative),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.supportFeedbackNeutral),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await prefs.setBool(_prompted, true);
              if (!mounted ||
                  Supabase.instance.client.auth.currentUser?.id != userId) {
                return;
              }
              final review = InAppReview.instance;
              if (await review.isAvailable()) await review.requestReview();
            },
            child: Text(l10n.supportFeedbackPositive),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
