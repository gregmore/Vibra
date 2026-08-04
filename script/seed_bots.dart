// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('--- Avvio Script Seeding Bot ---');

  // 1. Carica le variabili d'ambiente
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('Errore: File .env non trovato!');
    return;
  }

  final env = envFile.readAsStringSync();
  final regexUrl = RegExp(r'SUPABASE_URL=(.*)');
  final regexKey = RegExp(r'SUPABASE_ANON_KEY=(.*)');

  final urlMatch = regexUrl.firstMatch(env);
  final keyMatch = regexKey.firstMatch(env);

  if (urlMatch == null || keyMatch == null) {
    print('Errore: Chiavi Supabase non trovate nel .env');
    return;
  }

  final url = urlMatch.group(1)!.trim();
  final key = keyMatch.group(1)!.trim();

  print('Connessione a Supabase in corso...');
  final client = SupabaseClient(
    url,
    key,
    authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
  );

  // 2. Definisci i bot
  final bots = [
    {
      'email': 'giulia_bot@vibra.local',
      'password': 'Password123!',
      'username': 'giuli4',
      'display_name': 'Giulia',
      'bio':
          'Adoro i concerti indie e la techno! Cerco compagni per serate a Milano.',
      'avatar_url': 'https://i.pravatar.cc/300?img=5',
      'top_artists': [
        {
          'id': '1',
          'name': 'Calcutta',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5ebc52bc7291a92e1e0a811d017',
            },
          ],
        },
        {
          'id': '2',
          'name': 'Fred De Palma',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5eb4a7c06eb6ab490bb56658098',
            },
          ],
        },
      ],
      'top_tracks': [
        {
          'id': 't1',
          'name': 'Oroscopo',
          'artists': [
            {'name': 'Calcutta'},
          ],
        },
      ],
      'top_genres': ['indie it', 'techno', 'pop'],
    },
    {
      'email': 'marco_bot@vibra.local',
      'password': 'Password123!',
      'username': 'marcone_99',
      'display_name': 'Marco',
      'bio': 'Trap e rap. Se non si poga non mi diverto. Roma.',
      'avatar_url': 'https://i.pravatar.cc/300?img=11',
      'top_artists': [
        {
          'id': '3',
          'name': 'Sfera Ebbasta',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5eb3b1b6eb98f3b0e3532f83db5',
            },
          ],
        },
        {
          'id': '4',
          'name': 'Lazza',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5eb00e6a8e5621453bbcc1f3b23',
            },
          ],
        },
      ],
      'top_tracks': [
        {
          'id': 't2',
          'name': 'Cenere',
          'artists': [
            {'name': 'Lazza'},
          ],
        },
      ],
      'top_genres': ['trap', 'rap', 'hip hop'],
    },
    {
      'email': 'sofia_bot@vibra.local',
      'password': 'Password123!',
      'username': 'sofi_dj',
      'display_name': 'Sofia',
      'bio': 'Ascolto un po\' di tutto ma vivo per l\'elettronica. 🎧',
      'avatar_url': 'https://i.pravatar.cc/300?img=9',
      'top_artists': [
        {
          'id': '5',
          'name': 'Daft Punk',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5eb3cb0da867d7a46ed258cb253',
            },
          ],
        },
        {
          'id': '6',
          'name': 'Peggy Gou',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5eba44f7a6f23ad5b50d876527b',
            },
          ],
        },
      ],
      'top_tracks': [
        {
          'id': 't3',
          'name': 'One More Time',
          'artists': [
            {'name': 'Daft Punk'},
          ],
        },
      ],
      'top_genres': ['electronic', 'house', 'dance'],
    },
    {
      'email': 'luca_metal@vibra.local',
      'password': 'Password123!',
      'username': 'luca_metal99',
      'display_name': 'Luca',
      'bio':
          'Metallaro dal cuore tenero. Cerco qualcuno con cui andare al prossimo concerto dei Metallica. 🎸🤘',
      'avatar_url': 'https://i.pravatar.cc/300?img=68',
      'top_artists': [
        {
          'id': '7',
          'name': 'Metallica',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5eb8101d13bdd630b0889acd2fd',
            },
          ],
        },
        {
          'id': '8',
          'name': 'Slipknot',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5eb32dbba6cb50cf39570c9a44c',
            },
          ],
        },
      ],
      'top_tracks': [
        {
          'id': 't4',
          'name': 'Master of Puppets',
          'artists': [
            {'name': 'Metallica'},
          ],
        },
      ],
      'top_genres': ['metal', 'rock', 'heavy metal'],
    },
    {
      'email': 'alessia_kpop@vibra.local',
      'password': 'Password123!',
      'username': 'aly_kpop',
      'display_name': 'Alessia',
      'bio':
          'Army forever! ✨ Cerco amici/amiche per ballare e condividere la passione per il K-pop! 💖',
      'avatar_url': 'https://i.pravatar.cc/300?img=47',
      'top_artists': [
        {
          'id': '9',
          'name': 'BTS',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5eb5704a64f34fe29ff73ab56bb',
            },
          ],
        },
        {
          'id': '10',
          'name': 'BLACKPINK',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5ebc7eaeca5aed17cea0f6316ef',
            },
          ],
        },
      ],
      'top_tracks': [
        {
          'id': 't5',
          'name': 'Dynamite',
          'artists': [
            {'name': 'BTS'},
          ],
        },
      ],
      'top_genres': ['k-pop', 'pop', 'k-pop girl group'],
    },
    {
      'email': 'chiara_latino@vibra.local',
      'password': 'Password123!',
      'username': 'chiara_fiesta',
      'display_name': 'Chiara',
      'bio':
          'Reggaeton, bachata e tanto divertimento! 💃🍹 Chi viene a ballare stasera?',
      'avatar_url': 'https://i.pravatar.cc/300?img=32',
      'top_artists': [
        {
          'id': '13',
          'name': 'Bad Bunny',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5eb957c7b80a2cdbcfbd12797e8',
            },
          ],
        },
        {
          'id': '14',
          'name': 'Rosalía',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5ebe8baee9e8306df9a17112001',
            },
          ],
        },
      ],
      'top_tracks': [
        {
          'id': 't7',
          'name': 'Me Porto Bonito',
          'artists': [
            {'name': 'Bad Bunny'},
          ],
        },
      ],
      'top_genres': ['reggaeton', 'latin', 'trap latino'],
    },
    {
      'email': 'davide_indie@vibra.local',
      'password': 'Password123!',
      'username': 'davide_indie_it',
      'display_name': 'Davide',
      'bio': 'IT-Pop e serate a parlare di niente. Offro io la prima birra. 🍺',
      'avatar_url': 'https://i.pravatar.cc/300?img=59',
      'top_artists': [
        {
          'id': '15',
          'name': 'Gazzelle',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5eb3e85e2b3471dfc888db73041',
            },
          ],
        },
        {
          'id': '16',
          'name': 'Frah Quintale',
          'images': [
            {
              'url':
                  'https://i.scdn.co/image/ab6761610000e5eb9e68cd02a8bf804e38e8e788',
            },
          ],
        },
      ],
      'top_tracks': [
        {
          'id': 't8',
          'name': 'Destri',
          'artists': [
            {'name': 'Gazzelle'},
          ],
        },
      ],
      'top_genres': ['indie it', 'indie pop', 'italian pop'],
    },
  ];

  // 3. Inserimento
  for (final bot in bots) {
    print('\nGenerazione bot: ${bot['display_name']}...');
    try {
      // Prova a fare il signUp
      final authResponse = await client.auth.signUp(
        email: bot['email'] as String,
        password: bot['password'] as String,
      );

      final userId = authResponse.user?.id;
      if (userId == null) {
        print(' - (Signup ignorato o già esistente, cerco ID nel DB...)');
      }

      // Essendo uno script senza admin key, per aggiornare i profili
      // dobbiamo usare la sessione appena creata con il signUp!
      // In Supabase, se il signUp ha successo, la sessione viene attivata per quel client.

      final currentUser = client.auth.currentUser;
      if (currentUser != null && currentUser.email == bot['email']) {
        print(' - Autenticato come $currentUser. Aggiornamento profilo...');

        // Upsert su users
        await client.from('users').upsert({
          'id': currentUser.id,
          'username': bot['username'],
          'display_name': bot['display_name'],
          'bio': bot['bio'],
          'avatar_url': bot['avatar_url'],
          'onboarding_completed': true,
        });

        // Upsert su music_profiles
        await client.from('music_profiles').upsert({
          'user_id': currentUser.id,
          'top_artists': jsonEncode(bot['top_artists']),
          'top_tracks': jsonEncode(bot['top_tracks']),
          'top_genres': bot['top_genres'],
        });

        print(' - Completato!');
      } else {
        print(
          ' - Errore: Sessione non attiva per ${bot['email']}. Forse l\'account esisteva già o richiede conferma email.',
        );
      }
    } catch (e, st) {
      print(' - Errore inaspettato: $e');
      print(st);
    }
  }

  print('\n--- Seeding Terminato ---');
  exit(0);
}
