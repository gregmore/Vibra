import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/vibra_theme_tokens.dart';
import '../../widgets/common/vibra_page_scaffold.dart';

class _Faq {
  const _Faq(this.category, this.question, this.answer);
  final String category;
  final String question;
  final String answer;
}

const _faqs = <_Faq>[
  _Faq(
    'Account',
    'Non riesco ad accedere',
    'Controlla email e password, poi prova a chiudere e riaprire Vibra. Se l’accesso continua a non riuscire, usa “Segnala un problema” e indica il provider usato.',
  ),
  _Faq(
    'Account',
    'Come esco dall’account?',
    'Vai in Profilo > Impostazioni > Esci. Per rimuovere la sessione da tutti i dispositivi, scegli “Esci da tutti i dispositivi”.',
  ),
  _Faq(
    'Account',
    'Come cancello il mio account?',
    'Vai in Profilo > Impostazioni > Elimina account. Ti verrà chiesta una conferma: l’operazione rimuove i dati dell’account secondo la nostra informativa privacy.',
  ),
  _Faq(
    'Eventi',
    'Perché non vedo eventi vicino a me?',
    'Verifica di aver concesso la posizione e prova ad ampliare il raggio di ricerca. La disponibilità dipende anche dalle fonti degli eventi nella tua zona.',
  ),
  _Faq(
    'Eventi',
    'Un evento o i biglietti non si aprono',
    'Gli eventi e i biglietti provengono da partner esterni. Riprova più tardi; se il problema persiste, invia una segnalazione indicando l’evento.',
  ),
  _Faq(
    'Chat/Match',
    'Come viene calcolato il match score?',
    'Il punteggio confronta soprattutto artisti e generi musicali in comune, con un piccolo bonus per gusti più di nicchia. È un’indicazione di affinità, non una garanzia.',
  ),
  _Faq(
    'Chat/Match',
    'Come blocco o segnalo un utente?',
    'Apri il profilo dell’utente e usa il menu di sicurezza per bloccarlo o segnalarlo. Il blocco interrompe le interazioni future; le segnalazioni vengono esaminate dal team.',
  ),
  _Faq(
    'Spotify',
    'Come collego Spotify?',
    'Vai in Profilo > Impostazioni > Account Spotify e tocca per collegarlo. Completa l’autorizzazione nella finestra Spotify e torna automaticamente in Vibra.',
  ),
  _Faq(
    'Spotify',
    'Come scollego Spotify?',
    'Vai in Profilo > Impostazioni > Account Spotify e scegli “Scollega”. Potrai ricollegarlo quando vuoi.',
  ),
  _Faq(
    'Spotify',
    'Il collegamento Spotify non riesce',
    'Verifica la connessione e che l’autorizzazione sia stata completata. Non devi condividere password o token con il supporto: la segnalazione include solo dati tecnici anonimizzati.',
  ),
  _Faq(
    'Privacy',
    'Quali dati invia una segnalazione?',
    'Versione app e sistema operativo, ultimo endpoint che ha avuto errore e pochi log tecnici recenti ripuliti da password, token e identificativi. Puoi anche allegare uno screenshot.',
  ),
  _Faq(
    'Privacy',
    'Come esercito i miei diritti sui dati?',
    'Vai in Profilo > Impostazioni > Privacy e dati personali per gestire consensi ed esportare i dati. Per richieste aggiuntive scrivi a privacy@vibra.app.',
  ),
];

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String _query = '';
  String _category = 'Tutte';

  @override
  Widget build(BuildContext context) {
    final t = context.vibraTokens;
    final categories = [
      'Tutte',
      ...{for (final faq in _faqs) faq.category},
    ];
    final visible = _faqs.where((faq) {
      final matchesCategory = _category == 'Tutte' || faq.category == _category;
      final text = '${faq.question} ${faq.answer}'.toLowerCase();
      return matchesCategory && text.contains(_query.toLowerCase());
    }).toList();
    return VibraPageScaffold(
      appBar: AppBar(title: const Text('Centro assistenza')),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Risposte rapide e assistenza. Ti rispondiamo entro 48 ore.',
            style: TextStyle(color: t.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cerca nelle domande frequenti',
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
                        label: Text(category),
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
                subtitle: Text(faq.category),
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
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'Nessuna risposta trovata. Prova con un’altra ricerca.',
                ),
              ),
            ),
          const SizedBox(height: 16),
          ListTile(
            leading: Icon(Icons.email_outlined, color: t.accentPrimary),
            title: const Text('Hai ancora bisogno di aiuto?'),
            subtitle: Text(
              '${AppConstants.supportEmail} · risposta ${AppConstants.supportResponseSla}',
            ),
          ),
        ],
      ),
    );
  }
}
