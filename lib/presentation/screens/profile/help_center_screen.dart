import 'package:vibra/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../widgets/common/vibra_page_scaffold.dart';

class _Faq {
  const _Faq(
    this.category,
    this.question,
    this.answer, {
    this.musicOnly = false,
  });
  final String category;
  final String question;
  final String answer;
  final bool musicOnly;
}

List<_Faq> _localizedFaqs(AppLocalizations l10n) => [
  _Faq('account', l10n.helpLoginQuestion, l10n.helpLoginAnswer),
  _Faq('account', l10n.helpLogoutQuestion, l10n.helpLogoutAnswer),
  _Faq('account', l10n.helpDeleteQuestion, l10n.helpDeleteAnswer),
  _Faq('events', l10n.helpEventsQuestion, l10n.helpEventsAnswer),
  _Faq('events', l10n.helpTicketsQuestion, l10n.helpTicketsAnswer),
  _Faq(
    'chat',
    l10n.helpAffinityQuestion,
    l10n.helpAffinityAnswer,
    musicOnly: true,
  ),
  _Faq('chat', l10n.helpBlockQuestion, l10n.helpBlockAnswer),
  _Faq(
    'spotify',
    l10n.helpSpotifyConnectQuestion,
    l10n.helpSpotifyConnectAnswer,
    musicOnly: true,
  ),
  _Faq(
    'spotify',
    l10n.helpSpotifyDisconnectQuestion,
    l10n.helpSpotifyDisconnectAnswer,
    musicOnly: true,
  ),
  _Faq(
    'spotify',
    l10n.helpSpotifyErrorQuestion,
    l10n.helpSpotifyErrorAnswer,
    musicOnly: true,
  ),
  _Faq('privacy', l10n.helpReportDataQuestion, l10n.helpReportDataAnswer),
  _Faq(
    'privacy',
    l10n.helpPrivacyQuestion,
    l10n.helpPrivacyAnswer(AppConstants.privacyEmail),
  ),
];

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String _query = '';
  String _category = 'all';

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final l10n = AppLocalizations.of(context)!;
    final availableFaqs = _localizedFaqs(
      l10n,
    ).where((faq) => AppConstants.spotifyEnabled || !faq.musicOnly).toList();
    final categories = [
      'all',
      ...{for (final faq in availableFaqs) faq.category},
    ];
    final categoryLabels = {
      'all': l10n.helpCategoryAll,
      'account': l10n.helpCategoryAccount,
      'events': l10n.navEvents,
      'chat': AppConstants.spotifyEnabled
          ? l10n.helpCategoryChatMatch
          : l10n.navChat,
      'spotify': 'Spotify',
      'privacy': l10n.helpCategoryPrivacy,
    };
    final visible = availableFaqs.where((faq) {
      final matchesCategory = _category == 'all' || faq.category == _category;
      final text = '${faq.question} ${faq.answer}'.toLowerCase();
      return matchesCategory && text.contains(_query.toLowerCase());
    }).toList();
    return VibraPageScaffold(
      appBar: AppBar(title: Text(l10n.settingsHelpCenter)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.helpIntro, style: TextStyle(color: t.textSecondary)),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: l10n.helpSearchHint,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(categoryLabels[category]!),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          ...visible.map(
            (faq) => Card(
              child: ExpansionTile(
                title: Text(faq.question),
                subtitle: Text(categoryLabels[faq.category]!),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  Text(
                    faq.answer,
                    style: TextStyle(color: t.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text(l10n.helpSearchEmpty)),
            ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.email_outlined, color: t.accentPrimary),
            title: Text(l10n.helpNeedMore),
            subtitle: Text(
              l10n.supportAlternativeContact(AppConstants.supportEmail),
            ),
          ),
        ],
      ),
    );
  }
}
