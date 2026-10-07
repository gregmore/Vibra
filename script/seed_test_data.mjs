#!/usr/bin/env node

/**
 * Vibra deterministic QA data seeder.
 *
 * Uses only Node's built-in fetch so the Flutter repository does not need an
 * npm dependency tree. Authentication users are managed through Supabase's
 * Admin API; application data is written through PostgREST with service_role.
 */

import { webcrypto } from 'node:crypto';

const SEED_NAMESPACE = 'vibra_e2e_v1';
const EMAIL_PREFIX = 'vibra_test_';
const EMAIL_DOMAIN = 'example.com';
const EVENT_PREFIX = 'vibra-e2e-';
const MIN_USERS = 10;
const DEFAULT_PASSWORD = 'Vibra-Test!2026';
const RESET_CONFIRMATION = 'RESET_TEST_DATA';
const ALLOWED_ENVIRONMENTS = new Set([
  'local',
  'development',
  'dev',
  'staging',
  'test',
]);

const BASE_USERS = [
  {
    key: 'complete',
    number: 1,
    scenario: 'Profilo completo',
    username: 'test_complete',
    displayName: 'TEST Giulia Completa',
  },
  {
    key: 'minimal',
    number: 2,
    scenario: 'Profilo minimale',
    username: 'test_minimal',
    displayName: null,
  },
  {
    key: 'half_onboarding',
    number: 3,
    scenario: 'Onboarding fermo prima di Spotify',
    username: 'test_half_onboarding',
    displayName: 'TEST Nico Onboarding',
  },
  {
    key: 'many_matches',
    number: 4,
    scenario: 'Molti match e stati sociali',
    username: 'test_many_matches',
    displayName: 'TEST Marta Affinità',
  },
  {
    key: 'active_chat',
    number: 5,
    scenario: 'Chat attive e non letti',
    username: 'test_active_chat',
    displayName: 'TEST Leo Chat',
  },
  {
    key: 'blocker',
    number: 6,
    scenario: 'Utente bloccante',
    username: 'test_blocker',
    displayName: 'TEST Sara Blocker',
  },
  {
    key: 'spotify_expired',
    number: 7,
    scenario: 'Spotify scaduto e utente bloccato',
    username: 'test_spotify_expired',
    displayName: 'TEST Omar Spotify KO',
  },
  {
    key: 'mixed_events',
    number: 8,
    scenario: 'Eventi salvati misti',
    username: 'test_mixed_events',
    displayName: 'TEST Alice Eventi',
  },
  {
    key: 'brand_new',
    number: 9,
    scenario: 'Auth appena registrata senza profilo pubblico',
    username: 'test_brand_new',
    displayName: 'TEST Nuovo Utente',
    authOnly: true,
  },
  {
    key: 'far_away',
    number: 10,
    scenario: 'Utente geograficamente lontano',
    username: 'test_far_away',
    displayName: 'TEST Vale Lontana',
  },
];

const EVENT_IDS = {
  indie: 'e0000000-0000-4000-8000-000000000001',
  techno: 'e0000000-0000-4000-8000-000000000002',
  rock: 'e0000000-0000-4000-8000-000000000003',
  far: 'e0000000-0000-4000-8000-000000000004',
  past: 'e0000000-0000-4000-8000-000000000005',
  soldOut: 'e0000000-0000-4000-8000-000000000006',
  canceled: 'e0000000-0000-4000-8000-000000000007',
  postponed: 'e0000000-0000-4000-8000-000000000008',
};

function emailFor(user) {
  return `${EMAIL_PREFIX}${String(user.number).padStart(2, '0')}_${user.key}@${EMAIL_DOMAIN}`;
}

function parseArgs(argv) {
  const args = [...argv];
  let command = 'seed';
  if (args[0] && !args[0].startsWith('-')) command = args.shift();

  const options = {
    command,
    users: MIN_USERS,
    city: 'Milano',
    latitude: 45.4642,
    longitude: 9.19,
    farCity: 'Roma',
    farLatitude: 41.9028,
    farLongitude: 12.4964,
    allowRemote: false,
    reset: false,
    dryRun: false,
    confirm: '',
  };

  const takesValue = new Set([
    '--users', '--city', '--lat', '--lon', '--far-city', '--far-lat',
    '--far-lon', '--confirm',
  ]);

  while (args.length > 0) {
    const flag = args.shift();
    if (takesValue.has(flag)) {
      if (args.length === 0) fail(`Valore mancante per ${flag}`);
      const value = args.shift();
      if (flag === '--users') options.users = Number(value);
      if (flag === '--city') options.city = value;
      if (flag === '--lat') options.latitude = Number(value);
      if (flag === '--lon') options.longitude = Number(value);
      if (flag === '--far-city') options.farCity = value;
      if (flag === '--far-lat') options.farLatitude = Number(value);
      if (flag === '--far-lon') options.farLongitude = Number(value);
      if (flag === '--confirm') options.confirm = value;
      continue;
    }
    if (flag === '--allow-remote') options.allowRemote = true;
    else if (flag === '--reset') options.reset = true;
    else if (flag === '--dry-run') options.dryRun = true;
    else if (flag === '--help' || flag === '-h') options.command = 'help';
    else fail(`Opzione sconosciuta: ${flag}`);
  }

  if (!Number.isInteger(options.users) || options.users < MIN_USERS) {
    fail(`--users deve essere un intero >= ${MIN_USERS}`);
  }
  for (const [name, value, min, max] of [
    ['--lat', options.latitude, -90, 90],
    ['--lon', options.longitude, -180, 180],
    ['--far-lat', options.farLatitude, -90, 90],
    ['--far-lon', options.farLongitude, -180, 180],
  ]) {
    if (!Number.isFinite(value) || value < min || value > max) {
      fail(`${name} non è una coordinata valida`);
    }
  }
  return options;
}

function usage() {
  console.log(`
Vibra QA seed (solo local/dev/staging)

Uso:
  node script/seed_test_data.mjs seed [opzioni]
  node script/seed_test_data.mjs seed --reset --confirm ${RESET_CONFIRMATION}
  node script/seed_test_data.mjs reset --confirm ${RESET_CONFIRMATION}
  node script/seed_test_data.mjs clean --confirm ${RESET_CONFIRMATION}
  node script/seed_test_data.mjs fixtures

Variabili obbligatorie per seed/reset/clean:
  VIBRA_ENV=local|development|staging|test
  SUPABASE_URL=...
  SUPABASE_SERVICE_ROLE_KEY=...

Per uno staging remoto servono anche:
  VIBRA_TEST_PROJECT_REF=<ref esatto del progetto>
  --allow-remote

Opzioni:
  --users N        Minimo 10; gli utenti oltre il decimo sono profili load-test
  --city NOME      Città base (default Milano)
  --lat/--lon      Coordinate città base
  --far-city NOME  Città dell'utente lontano (default Roma)
  --far-lat/--far-lon
  --reset          Pulisce il namespace e ricrea lo stato noto
  --dry-run        Valida e mostra il piano senza chiamare Supabase
`);
}

function fail(message) {
  throw new Error(message);
}

function requiredEnv(name) {
  const value = process.env[name]?.trim();
  if (!value) fail(`Variabile obbligatoria mancante: ${name}`);
  return value;
}

function assertSafeTarget(options) {
  const environment = requiredEnv('VIBRA_ENV').toLowerCase();
  if (!ALLOWED_ENVIRONMENTS.has(environment) || environment.includes('prod')) {
    fail(`Ambiente vietato per il seed: ${environment}`);
  }

  const url = new URL(requiredEnv('SUPABASE_URL'));
  const local = ['127.0.0.1', 'localhost', 'host.docker.internal'].includes(
    url.hostname,
  );

  if (!local) {
    if (!options.allowRemote) {
      fail('Target remoto bloccato: aggiungi --allow-remote solo per lo staging.');
    }
    const allowlistedRef = requiredEnv('VIBRA_TEST_PROJECT_REF');
    const targetRef = url.hostname.split('.')[0];
    if (targetRef !== allowlistedRef) {
      fail(
        `Project ref non consentito: target=${targetRef}, allowlist=${allowlistedRef}`,
      );
    }
    if (environment !== 'staging' && environment !== 'test') {
      fail('Un target remoto richiede VIBRA_ENV=staging oppure test.');
    }
  }

  const serviceKey = requiredEnv('SUPABASE_SERVICE_ROLE_KEY');
  if (serviceKey === process.env.SUPABASE_ANON_KEY) {
    fail('SUPABASE_SERVICE_ROLE_KEY coincide con la chiave anon: configurazione non valida.');
  }

  return { environment, url: url.origin, serviceKey, local };
}

class SupabaseAdmin {
  constructor({ url, serviceKey }) {
    this.url = url.replace(/\/$/, '');
    this.serviceKey = serviceKey;
  }

  async request(path, { method = 'GET', body, prefer, auth = false } = {}) {
    const prefix = auth ? '/auth/v1' : '/rest/v1';
    const response = await fetch(`${this.url}${prefix}${path}`, {
      method,
      headers: {
        apikey: this.serviceKey,
        Authorization: `Bearer ${this.serviceKey}`,
        ...(body === undefined ? {} : { 'Content-Type': 'application/json' }),
        ...(prefer ? { Prefer: prefer } : {}),
      },
      body: body === undefined ? undefined : JSON.stringify(body),
    });

    const text = await response.text();
    let payload = null;
    if (text) {
      try { payload = JSON.parse(text); } catch { payload = text; }
    }
    if (!response.ok) {
      const details = typeof payload === 'string'
        ? payload.slice(0, 500)
        : JSON.stringify(payload)?.slice(0, 500);
      fail(`${method} ${path} -> ${response.status}: ${details}`);
    }
    return payload;
  }

  async listAuthUsers() {
    const users = [];
    const perPage = 1000;
    for (let page = 1; ; page += 1) {
      const payload = await this.request(
        `/admin/users?page=${page}&per_page=${perPage}`,
        { auth: true },
      );
      const batch = Array.isArray(payload) ? payload : payload?.users ?? [];
      users.push(...batch);
      if (batch.length < perPage) break;
    }
    return users;
  }

  createAuthUser(body) {
    return this.request('/admin/users', { method: 'POST', body, auth: true });
  }

  updateAuthUser(id, body) {
    return this.request(`/admin/users/${id}`, {
      method: 'PUT', body, auth: true,
    });
  }

  deleteAuthUser(id) {
    return this.request(`/admin/users/${id}?should_soft_delete=false`, {
      method: 'DELETE', auth: true,
    });
  }

  rest(table, { method = 'GET', query = '', body, prefer } = {}) {
    return this.request(`/${table}${query ? `?${query}` : ''}`, {
      method, body, prefer,
    });
  }

  upsert(table, rows, conflict) {
    if (rows.length === 0) return Promise.resolve(null);
    const query = new URLSearchParams({ on_conflict: conflict }).toString();
    return this.rest(table, {
      method: 'POST',
      query,
      body: rows,
      prefer: 'resolution=merge-duplicates,return=minimal',
    });
  }
}

function authBody(user, password, existing = null) {
  const email = emailFor(user);
  return {
    email,
    password,
    email_confirm: true,
    user_metadata: {
      ...(existing?.user_metadata ?? {}),
      username: user.username,
      display_name: user.displayName ?? user.username,
      age_confirmed_18: true,
      fixture_scenario: user.scenario,
      seed_namespace: SEED_NAMESPACE,
    },
    app_metadata: {
      ...(existing?.app_metadata ?? {}),
      provider: 'email',
      providers: ['email'],
      is_test_user: true,
      seed_namespace: SEED_NAMESPACE,
    },
  };
}

function buildUsers(total) {
  const users = BASE_USERS.map((user) => ({ ...user }));
  for (let number = MIN_USERS + 1; number <= total; number += 1) {
    const suffix = String(number - MIN_USERS).padStart(3, '0');
    users.push({
      key: `load_${suffix}`,
      number,
      scenario: 'Profilo aggiuntivo per load/performance test',
      username: `test_load_${suffix}`,
      displayName: `TEST Load ${suffix}`,
      loadUser: true,
    });
  }
  return users;
}

async function ensureAuthUsers(api, users, password) {
  const existingUsers = await api.listAuthUsers();
  const byEmail = new Map(
    existingUsers.map((user) => [user.email?.toLowerCase(), user]),
  );
  const ids = new Map();

  for (const user of users) {
    const email = emailFor(user);
    const existing = byEmail.get(email.toLowerCase());
    let saved;
    if (existing) {
      saved = await api.updateAuthUser(
        existing.id,
        authBody(user, password, existing),
      );
    } else {
      saved = await api.createAuthUser(authBody(user, password));
    }
    const authUser = saved?.user ?? saved;
    if (!authUser?.id) fail(`Admin API non ha restituito l'id per ${email}`);
    ids.set(user.key, authUser.id);
  }
  return ids;
}

function isoOffset({ days = 0, hours = 0, minutes = 0 } = {}) {
  const value = new Date();
  value.setUTCDate(value.getUTCDate() + days);
  value.setUTCHours(value.getUTCHours() + hours);
  value.setUTCMinutes(value.getUTCMinutes() + minutes);
  return value.toISOString();
}

function profileRows(users, ids, options) {
  const center = { lat: options.latitude, lon: options.longitude };
  const base = {
    complete: {
      bio: 'TEST · Concerti indie, elettronica e nuove scoperte.',
      avatar_url: 'https://i.pravatar.cc/600?img=47',
      spotify_id: 'vibra_fixture_spotify_complete',
      onboarding_completed: true,
      onboarding_step: 'done',
      fcm_token: 'TEST_FCM_TOKEN_COMPLETE_DO_NOT_SEND',
      push_enabled: true,
      push_settings: { match: true, chat: true, events: true, retention: false },
      last_latitude: center.lat,
      last_longitude: center.lon,
      location_updated_at: isoOffset(),
    },
    minimal: {
      display_name: null,
      bio: null,
      avatar_url: null,
      spotify_id: null,
      onboarding_completed: true,
      onboarding_step: 'done',
      fcm_token: null,
      push_enabled: false,
      push_settings: {},
      last_latitude: null,
      last_longitude: null,
      location_updated_at: null,
    },
    half_onboarding: {
      bio: null,
      avatar_url: 'https://i.pravatar.cc/600?img=12',
      spotify_id: null,
      onboarding_completed: false,
      onboarding_step: 'spotify',
      fcm_token: null,
      push_enabled: false,
      push_settings: {},
      last_latitude: null,
      last_longitude: null,
      location_updated_at: null,
    },
    many_matches: {
      bio: 'TEST · Pop, indie e qualsiasi live con una buona energia.',
      avatar_url: 'https://i.pravatar.cc/600?img=44',
      spotify_id: 'vibra_fixture_spotify_matches',
      onboarding_completed: true,
      onboarding_step: 'done',
      push_enabled: true,
      push_settings: { match: true, chat: true, events: true, retention: false },
      last_latitude: center.lat + 0.004,
      last_longitude: center.lon + 0.003,
      location_updated_at: isoOffset(),
    },
    active_chat: {
      bio: 'TEST · Scrivimi se vuoi condividere un concerto.',
      avatar_url: 'https://i.pravatar.cc/600?img=7',
      spotify_id: 'vibra_fixture_spotify_chat',
      onboarding_completed: true,
      onboarding_step: 'done',
      push_enabled: true,
      push_settings: { match: true, chat: true, events: true, retention: false },
      last_latitude: center.lat + 0.002,
      last_longitude: center.lon - 0.003,
      location_updated_at: isoOffset(),
    },
    blocker: {
      bio: 'TEST · Scenario moderazione e blocco.',
      avatar_url: 'https://i.pravatar.cc/600?img=32',
      spotify_id: null,
      onboarding_completed: true,
      onboarding_step: 'done',
      push_enabled: false,
      push_settings: {},
      last_latitude: center.lat + 0.001,
      last_longitude: center.lon + 0.001,
      location_updated_at: isoOffset(),
    },
    spotify_expired: {
      bio: 'TEST · Connessione Spotify revocata.',
      avatar_url: 'https://i.pravatar.cc/600?img=33',
      spotify_id: 'vibra_fixture_spotify_expired',
      onboarding_completed: true,
      onboarding_step: 'done',
      push_enabled: true,
      push_settings: { match: true, chat: true, events: true, retention: false },
      last_latitude: center.lat - 0.003,
      last_longitude: center.lon + 0.002,
      location_updated_at: isoOffset(),
    },
    mixed_events: {
      bio: 'TEST · Agenda concerti piena, inclusi aggiornamenti critici.',
      avatar_url: 'https://i.pravatar.cc/600?img=56',
      spotify_id: 'vibra_fixture_spotify_events',
      onboarding_completed: true,
      onboarding_step: 'done',
      push_enabled: true,
      push_settings: { match: true, chat: true, events: true, retention: false },
      last_latitude: center.lat - 0.002,
      last_longitude: center.lon - 0.004,
      location_updated_at: isoOffset(),
    },
    far_away: {
      bio: `TEST · Profilo lontano, base ${options.farCity}.`,
      avatar_url: 'https://i.pravatar.cc/600?img=5',
      spotify_id: 'vibra_fixture_spotify_far',
      onboarding_completed: true,
      onboarding_step: 'done',
      push_enabled: true,
      push_settings: { match: true, chat: true, events: true, retention: false },
      last_latitude: options.farLatitude,
      last_longitude: options.farLongitude,
      location_updated_at: isoOffset(),
    },
  };

  return users
    .filter((user) => !user.authOnly)
    .map((user, index) => {
      const loadOffset = user.loadUser
        ? {
            bio: 'TEST · Profilo sintetico per carico.',
            avatar_url: null,
            spotify_id: null,
            onboarding_completed: true,
            onboarding_step: 'done',
            push_enabled: false,
            push_settings: {},
            last_latitude: center.lat + ((index % 20) - 10) * 0.002,
            last_longitude: center.lon + ((index % 17) - 8) * 0.002,
            location_updated_at: isoOffset(),
          }
        : base[user.key];
      return {
        id: ids.get(user.key),
        email: emailFor(user),
        username: user.username,
        display_name: user.displayName,
        is_test_user: true,
        bio: null,
        avatar_url: null,
        spotify_id: null,
        onboarding_completed: false,
        onboarding_step: null,
        fcm_token: null,
        push_enabled: false,
        push_settings: {},
        last_latitude: null,
        last_longitude: null,
        location_updated_at: null,
        last_active_at: isoOffset({ hours: -(index % 48) }),
        ...loadOffset,
      };
    });
}

const MUSIC_LIBRARY = {
  indie: {
    artists: [
      { id: 'calcutta', name: 'Calcutta', score: 100 },
      { id: 'cosmo', name: 'Cosmo', score: 92 },
      { id: 'ari_re', name: 'Ariete', score: 84 },
    ],
    genres: [
      { genre: 'indie italiano', weight: 1 },
      { genre: 'cantautorato', weight: 0.78 },
      { genre: 'electropop', weight: 0.55 },
      { genre: 'alternative dance', weight: 0.42 },
      { genre: 'pop elettronico', weight: 0.31 },
    ],
    tracks: [
      { id: 'fixture-kati', name: 'Kati', artist: 'Calcutta', score: 100 },
      { id: 'fixture-sei-la-mia-citta', name: 'Sei la mia città', artist: 'Cosmo', score: 91 },
    ],
    embedding: '[0.92,0.84,0.71,0.63,0.44,0.31,0.22,0.15,0.08,0.04]',
  },
  pop: {
    artists: [
      { id: 'dua_lipa', name: 'Dua Lipa', score: 100 },
      { id: 'taylor_swift', name: 'Taylor Swift', score: 93 },
      { id: 'ari_re', name: 'Ariete', score: 75 },
    ],
    genres: [
      { genre: 'pop', weight: 1 },
      { genre: 'dance pop', weight: 0.82 },
      { genre: 'indie italiano', weight: 0.48 },
    ],
    tracks: [{ id: 'fixture-houdini', name: 'Houdini', artist: 'Dua Lipa', score: 100 }],
    embedding: '[0.87,0.78,0.69,0.58,0.42,0.36,0.25,0.17,0.09,0.05]',
  },
  electronic: {
    artists: [
      { id: 'fred_again', name: 'Fred again..', score: 100 },
      { id: 'bicep', name: 'Bicep', score: 91 },
      { id: 'cosmo', name: 'Cosmo', score: 72 },
    ],
    genres: [
      { genre: 'electronic', weight: 1 },
      { genre: 'house', weight: 0.83 },
      { genre: 'electropop', weight: 0.47 },
    ],
    tracks: [{ id: 'fixture-glue', name: 'Glue', artist: 'Bicep', score: 100 }],
    embedding: '[0.66,0.58,0.47,0.39,0.81,0.72,0.54,0.31,0.18,0.09]',
  },
  rock: {
    artists: [
      { id: 'maneskin', name: 'Måneskin', score: 100 },
      { id: 'muse', name: 'Muse', score: 88 },
      { id: 'metallica', name: 'Metallica', score: 78 },
    ],
    genres: [
      { genre: 'rock', weight: 1 },
      { genre: 'alternative rock', weight: 0.8 },
      { genre: 'metal', weight: 0.55 },
    ],
    tracks: [{ id: 'fixture-supermassive', name: 'Supermassive Black Hole', artist: 'Muse', score: 100 }],
    embedding: '[0.21,0.18,0.14,0.11,0.31,0.45,0.63,0.79,0.88,0.94]',
  },
};

function heatmap(seed) {
  return Array.from({ length: 7 }, (_, day) => ({
    day,
    hours: Array.from({ length: 24 }, (_, hour) =>
      Number((((seed + day * 3 + hour) % 10) / 10).toFixed(1))),
  }));
}

function musicRows(users, ids) {
  const variants = {
    complete: 'indie',
    many_matches: 'pop',
    active_chat: 'electronic',
    spotify_expired: 'rock',
    mixed_events: 'indie',
    far_away: 'electronic',
  };
  return users
    .filter((user) => variants[user.key] || user.loadUser)
    .map((user, index) => {
      const library = MUSIC_LIBRARY[
        variants[user.key] ?? ['indie', 'pop', 'electronic', 'rock'][index % 4]
      ];
      return {
        user_id: ids.get(user.key),
        top_artists: library.artists,
        top_genres: library.genres,
        top_tracks: library.tracks,
        listening_heatmap: heatmap(index + 1),
        audio_features: { fixture: true, energy: 0.72, danceability: 0.68 },
        embedding: library.embedding,
        last_synced_at: isoOffset({ hours: user.key === 'spotify_expired' ? -240 : -2 }),
      };
    });
}

function eventRows(options) {
  const near = (latDelta, lonDelta) => ({
    latitude: options.latitude + latDelta,
    longitude: options.longitude + lonDelta,
    city: options.city,
    country: 'IT',
  });
  const common = {
    source: 'ticketmaster',
    is_test_data: true,
    image_url: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=1200&q=80',
    ticket_url: 'https://example.com/vibra-test-ticket',
    created_at: isoOffset({ days: -2 }),
  };
  return [
    {
      ...common, id: EVENT_IDS.indie, external_id: `${EVENT_PREFIX}indie-near`,
      name: 'TEST Indie Frequencies', artist_name: 'Calcutta', artist_spotify_id: 'calcutta',
      venue_name: 'TEST Arena Centro', ...near(0.006, 0.004), event_date: isoOffset({ days: 7 }),
      price_min: 28, price_max: 58, status: 'onsale',
      description: 'Evento sintetico indie vicino alla città base.',
      embedding: MUSIC_LIBRARY.indie.embedding,
    },
    {
      ...common, id: EVENT_IDS.techno, external_id: `${EVENT_PREFIX}techno-near`,
      name: 'TEST Neon Warehouse', artist_name: 'Bicep', artist_spotify_id: 'bicep',
      venue_name: 'TEST Warehouse', ...near(0.018, -0.01), event_date: isoOffset({ days: 14 }),
      price_min: 35, price_max: 70, status: 'onsale',
      description: 'Evento elettronico a distanza media.', embedding: MUSIC_LIBRARY.electronic.embedding,
    },
    {
      ...common, id: EVENT_IDS.rock, external_id: `${EVENT_PREFIX}rock-outer`,
      name: 'TEST Rock District', artist_name: 'Måneskin', artist_spotify_id: 'maneskin',
      venue_name: 'TEST Stadium', ...near(0.11, 0.09), event_date: isoOffset({ days: 21 }),
      price_min: 45, price_max: 110, status: 'onsale',
      description: 'Evento rock fuori dal raggio breve.', embedding: MUSIC_LIBRARY.rock.embedding,
    },
    {
      ...common, id: EVENT_IDS.far, external_id: `${EVENT_PREFIX}far-city`,
      name: 'TEST Far City Sessions', artist_name: 'Fred again..', artist_spotify_id: 'fred_again',
      venue_name: 'TEST Far Arena', city: options.farCity, country: 'IT',
      latitude: options.farLatitude, longitude: options.farLongitude,
      event_date: isoOffset({ days: 10 }), price_min: 30, price_max: 80,
      status: 'onsale', description: 'Evento vicino solo al profilo geografico lontano.',
      embedding: MUSIC_LIBRARY.electronic.embedding,
    },
    {
      ...common, id: EVENT_IDS.past, external_id: `${EVENT_PREFIX}past`,
      name: 'TEST Memories Festival', artist_name: 'Cosmo', artist_spotify_id: 'cosmo',
      venue_name: 'TEST Old Club', ...near(0.003, -0.002), event_date: isoOffset({ days: -45 }),
      price_min: 25, price_max: 45, status: 'offsale',
      description: 'Evento passato per la sezione storico.', embedding: MUSIC_LIBRARY.indie.embedding,
    },
    {
      ...common, id: EVENT_IDS.soldOut, external_id: `${EVENT_PREFIX}sold-out`,
      name: 'TEST Sold Out Pop Night', artist_name: 'Dua Lipa', artist_spotify_id: 'dua_lipa',
      venue_name: 'TEST Forum', ...near(0.009, 0.006), event_date: isoOffset({ days: 18 }),
      price_min: 55, price_max: 120, status: 'offsale',
      description: 'FIXTURE_STATE=SOLD_OUT · Salvato quando era in vendita, ora sold-out.',
      embedding: MUSIC_LIBRARY.pop.embedding,
    },
    {
      ...common, id: EVENT_IDS.canceled, external_id: `${EVENT_PREFIX}canceled`,
      name: 'TEST Canceled Live', artist_name: 'Muse', artist_spotify_id: 'muse',
      venue_name: 'TEST Park', ...near(-0.012, 0.008), event_date: isoOffset({ days: 25 }),
      price_min: 40, price_max: 95, status: 'canceled',
      description: 'Evento cancellato dopo il salvataggio.', embedding: MUSIC_LIBRARY.rock.embedding,
    },
    {
      ...common, id: EVENT_IDS.postponed, external_id: `${EVENT_PREFIX}postponed`,
      name: 'TEST Postponed Electronic Day', artist_name: 'Fred again..', artist_spotify_id: 'fred_again',
      venue_name: 'TEST Garden', ...near(-0.02, -0.012), event_date: isoOffset({ days: 35 }),
      price_min: 32, price_max: 65, status: 'postponed',
      description: 'Evento rinviato per testare tutti gli stati card.',
      embedding: MUSIC_LIBRARY.electronic.embedding,
    },
  ];
}

function canonicalPair(left, right) {
  return left < right ? [left, right] : [right, left];
}

function matchRows(users, ids) {
  const definitions = [
    ['a0000000-0000-4000-8000-000000000001', 'complete', 'many_matches', 94, 3, 3],
    ['a0000000-0000-4000-8000-000000000002', 'minimal', 'many_matches', 61, 0, 1],
    ['a0000000-0000-4000-8000-000000000003', 'half_onboarding', 'many_matches', 28, 0, 0],
    ['a0000000-0000-4000-8000-000000000004', 'many_matches', 'active_chat', 84, 1, 2],
    ['a0000000-0000-4000-8000-000000000005', 'complete', 'active_chat', 76, 2, 2],
    ['a0000000-0000-4000-8000-000000000006', 'complete', 'mixed_events', 52, 2, 2],
    ['a0000000-0000-4000-8000-000000000007', 'complete', 'far_away', 19, 0, 0],
    ['a0000000-0000-4000-8000-000000000008', 'spotify_expired', 'many_matches', 43, 0, 1],
  ];
  let extra = 9;
  for (const user of users.filter((candidate) => candidate.loadUser)) {
    definitions.push([
      `a0000000-0000-4000-8000-${String(extra).padStart(12, '0')}`,
      'many_matches', user.key, 15 + ((extra * 17) % 81), extra % 4, extra % 5,
    ]);
    extra += 1;
  }
  return definitions.map(([id, leftKey, rightKey, compatibility, artists, genres]) => {
    const [userA, userB] = canonicalPair(ids.get(leftKey), ids.get(rightKey));
    return {
      id,
      user_id_a: userA,
      user_id_b: userB,
      compatibility,
      shared_artists: artists,
      shared_genres: genres,
      created_at: isoOffset({ days: -2 }),
      updated_at: isoOffset({ minutes: -10 }),
    };
  });
}

function friendshipRows(ids) {
  return [
    { id: 'f0000000-0000-4000-8000-000000000001', requester_id: ids.get('complete'), receiver_id: ids.get('many_matches'), status: 'accepted', created_at: isoOffset({ days: -20 }) },
    { id: 'f0000000-0000-4000-8000-000000000002', requester_id: ids.get('minimal'), receiver_id: ids.get('many_matches'), status: 'pending', created_at: isoOffset({ hours: -5 }) },
    { id: 'f0000000-0000-4000-8000-000000000003', requester_id: ids.get('many_matches'), receiver_id: ids.get('half_onboarding'), status: 'rejected', created_at: isoOffset({ days: -3 }) },
    { id: 'f0000000-0000-4000-8000-000000000004', requester_id: ids.get('many_matches'), receiver_id: ids.get('active_chat'), status: 'pending', created_at: isoOffset({ hours: -2 }) },
    { id: 'f0000000-0000-4000-8000-000000000005', requester_id: ids.get('complete'), receiver_id: ids.get('active_chat'), status: 'accepted', created_at: isoOffset({ days: -12 }) },
    { id: 'f0000000-0000-4000-8000-000000000006', requester_id: ids.get('active_chat'), receiver_id: ids.get('mixed_events'), status: 'accepted', created_at: isoOffset({ days: -9 }) },
  ];
}

function messageRows(ids) {
  const metadata = { seed_namespace: SEED_NAMESPACE };
  return [
    { id: 'd0000000-0000-4000-8000-000000000001', sender_id: ids.get('complete'), receiver_id: ids.get('active_chat'), content: 'Ciao Leo! Hai visto il TEST Indie Frequencies?', message_type: 'text', metadata, read_at: isoOffset({ days: -2, hours: 1 }), created_at: isoOffset({ days: -2 }) },
    { id: 'd0000000-0000-4000-8000-000000000002', sender_id: ids.get('active_chat'), receiver_id: ids.get('complete'), content: 'Sì, sembra perfetto. Ci organizziamo per arrivare prima?', message_type: 'text', metadata, read_at: isoOffset({ days: -2, hours: 2 }), created_at: isoOffset({ days: -2, hours: 1 }) },
    { id: 'd0000000-0000-4000-8000-000000000003', sender_id: ids.get('complete'), receiver_id: ids.get('active_chat'), content: 'Volentieri. Ti mando tutti i dettagli appena confermano gli orari; intanto salvo l’evento così riceviamo anche gli eventuali aggiornamenti.', message_type: 'text', metadata, read_at: null, created_at: isoOffset({ minutes: -35 }) },
    { id: 'd0000000-0000-4000-8000-000000000004', sender_id: ids.get('complete'), receiver_id: ids.get('active_chat'), content: 'Ultimo aggiornamento: apertura porte alle 19:30.', message_type: 'text', metadata, read_at: null, created_at: isoOffset({ minutes: -5 }) },
    { id: 'd0000000-0000-4000-8000-000000000005', sender_id: ids.get('mixed_events'), receiver_id: ids.get('active_chat'), content: 'Condivisione evento: TEST Sold Out Pop Night', message_type: 'event_share', metadata: { ...metadata, event_id: EVENT_IDS.soldOut, event_name: 'TEST Sold Out Pop Night', event_status: 'offsale' }, read_at: null, created_at: isoOffset({ minutes: -18 }) },
    { id: 'd0000000-0000-4000-8000-000000000006', sender_id: ids.get('active_chat'), receiver_id: ids.get('mixed_events'), content: 'Peccato sia sold-out. Teniamo d’occhio eventuali nuove disponibilità.', message_type: 'text', metadata, read_at: isoOffset({ minutes: -10 }), created_at: isoOffset({ minutes: -12 }) },
    { id: 'd0000000-0000-4000-8000-000000000007', sender_id: ids.get('half_onboarding'), receiver_id: ids.get('active_chat'), content: 'Ciao! Sto ancora completando il profilo, ma abbiamo gusti simili.', message_type: 'text', metadata, read_at: null, created_at: isoOffset({ hours: -4 }) },
  ];
}

function attendeeRows(ids) {
  return [
    { id: 'b0000000-0000-4000-8000-000000000001', user_id: ids.get('complete'), event_id: EVENT_IDS.indie, status: 'going', created_at: isoOffset({ days: -8 }) },
    { id: 'b0000000-0000-4000-8000-000000000002', user_id: ids.get('complete'), event_id: EVENT_IDS.techno, status: 'maybe', created_at: isoOffset({ days: -5 }) },
    { id: 'b0000000-0000-4000-8000-000000000003', user_id: ids.get('mixed_events'), event_id: EVENT_IDS.indie, status: 'going', created_at: isoOffset({ days: -9 }) },
    { id: 'b0000000-0000-4000-8000-000000000004', user_id: ids.get('mixed_events'), event_id: EVENT_IDS.past, status: 'going', created_at: isoOffset({ days: -60 }) },
    { id: 'b0000000-0000-4000-8000-000000000005', user_id: ids.get('mixed_events'), event_id: EVENT_IDS.soldOut, status: 'maybe', created_at: isoOffset({ days: -14 }) },
    { id: 'b0000000-0000-4000-8000-000000000006', user_id: ids.get('mixed_events'), event_id: EVENT_IDS.canceled, status: 'maybe', created_at: isoOffset({ days: -12 }) },
    { id: 'b0000000-0000-4000-8000-000000000007', user_id: ids.get('mixed_events'), event_id: EVENT_IDS.postponed, status: 'going', created_at: isoOffset({ days: -7 }) },
    { id: 'b0000000-0000-4000-8000-000000000008', user_id: ids.get('far_away'), event_id: EVENT_IDS.far, status: 'going', created_at: isoOffset({ days: -3 }) },
  ];
}

function privacyRows(users, ids) {
  return users.filter((user) => !user.authOnly).map((user) => {
    const full = !['minimal', 'half_onboarding', 'blocker'].includes(user.key) && !user.loadUser;
    return {
      user_id: ids.get(user.key),
      location_processing: full,
      spotify_matching: ['complete', 'many_matches', 'active_chat', 'spotify_expired', 'mixed_events', 'far_away'].includes(user.key),
      product_notifications: full,
      marketing_notifications: false,
      policy_version: '2026-08-27',
      updated_at: isoOffset(),
    };
  });
}

function notificationPreferenceRows(users, ids) {
  return users.filter((user) => !user.authOnly).map((user) => ({
    user_id: ids.get(user.key),
    retention_enabled: false,
    digest_frequency: 'never',
    retention_max_per_week: 0,
    timezone: 'Europe/Rome',
    quiet_hours_start: 22,
    quiet_hours_end: 8,
    updated_at: isoOffset(),
  }));
}

function notificationRows(ids) {
  return [
    {
      id: 'c0000000-0000-4000-8000-000000000001',
      user_id: ids.get('mixed_events'), type: 'event_update',
      title: 'Evento sold-out', body: 'TEST Sold Out Pop Night non ha più biglietti disponibili.',
      data: { event_id: EVENT_IDS.soldOut, seed_namespace: SEED_NAMESPACE, status: 'offsale' },
      read: false, created_at: isoOffset({ hours: -6 }),
    },
    {
      id: 'c0000000-0000-4000-8000-000000000002',
      user_id: ids.get('mixed_events'), type: 'event_update',
      title: 'Evento cancellato', body: 'TEST Canceled Live è stato cancellato.',
      data: { event_id: EVENT_IDS.canceled, seed_namespace: SEED_NAMESPACE, status: 'canceled' },
      read: false, created_at: isoOffset({ hours: -3 }),
    },
    {
      id: 'c0000000-0000-4000-8000-000000000003',
      user_id: ids.get('complete'), type: 'match',
      title: 'Nuova affinità TEST', body: 'Hai una nuova affinità musicale del 94%.',
      data: { other_user_id: ids.get('many_matches'), seed_namespace: SEED_NAMESPACE },
      read: true, created_at: isoOffset({ days: -2 }),
    },
  ];
}

function followRows(ids) {
  return [
    { follower_id: ids.get('complete'), following_id: ids.get('active_chat'), created_at: isoOffset({ days: -10 }) },
    { follower_id: ids.get('active_chat'), following_id: ids.get('complete'), created_at: isoOffset({ days: -9 }) },
    { follower_id: ids.get('mixed_events'), following_id: ids.get('active_chat'), created_at: isoOffset({ days: -8 }) },
  ];
}

async function encryptedFixtureToken(label) {
  const encodedKey = process.env.SPOTIFY_TOKEN_ENCRYPTION_KEY?.trim();
  if (!encodedKey) return 'v1.Zml4dHVyZV9pdg==.aW50ZW50aW9uYWxseV9pbnZhbGlk';
  const rawKey = Buffer.from(encodedKey, 'base64');
  if (rawKey.byteLength !== 32) {
    fail('SPOTIFY_TOKEN_ENCRYPTION_KEY deve decodificare esattamente 32 byte.');
  }
  const key = await webcrypto.subtle.importKey(
    'raw', rawKey, { name: 'AES-GCM' }, false, ['encrypt'],
  );
  const iv = webcrypto.getRandomValues(new Uint8Array(12));
  const plaintext = new TextEncoder().encode(`fixture:${SEED_NAMESPACE}:${label}`);
  const ciphertext = new Uint8Array(
    await webcrypto.subtle.encrypt({ name: 'AES-GCM', iv }, key, plaintext),
  );
  return `v1.${Buffer.from(iv).toString('base64')}.${Buffer.from(ciphertext).toString('base64')}`;
}

async function spotifyRows(ids) {
  return [
    {
      user_id: ids.get('complete'),
      spotify_user_id: 'vibra_fixture_spotify_complete',
      access_token_ciphertext: await encryptedFixtureToken('complete_access'),
      refresh_token_ciphertext: await encryptedFixtureToken('complete_refresh'),
      token_expires_at: isoOffset({ days: 30 }),
      connected_at: isoOffset({ days: -30 }),
      updated_at: isoOffset({ hours: -2 }),
    },
    {
      user_id: ids.get('spotify_expired'),
      spotify_user_id: 'vibra_fixture_spotify_expired',
      access_token_ciphertext: await encryptedFixtureToken('revoked_access'),
      refresh_token_ciphertext: await encryptedFixtureToken('revoked_refresh'),
      token_expires_at: isoOffset({ days: -30 }),
      connected_at: isoOffset({ days: -90 }),
      updated_at: isoOffset({ days: -30 }),
    },
  ];
}

async function verifySchema(api) {
  await api.rest('users', { query: 'select=id,is_test_user&limit=1' });
  await api.rest('events', { query: 'select=id,is_test_data&limit=1' });
}

async function seed(api, options) {
  const password = process.env.VIBRA_TEST_PASSWORD?.trim() || DEFAULT_PASSWORD;
  if (password.length < 12) fail('VIBRA_TEST_PASSWORD deve avere almeno 12 caratteri.');

  const users = buildUsers(options.users);
  const ids = await ensureAuthUsers(api, users, password);
  const profiles = profileRows(users, ids, options);

  await api.upsert('users', profiles, 'id');
  await api.upsert('privacy_preferences', privacyRows(users, ids), 'user_id');
  await api.upsert('notification_preferences', notificationPreferenceRows(users, ids), 'user_id');
  await api.upsert('music_profiles', musicRows(users, ids), 'user_id');
  await api.upsert('events', eventRows(options), 'id');
  await api.upsert('event_attendees', attendeeRows(ids), 'id');
  await api.upsert('user_matches', matchRows(users, ids), 'id');
  await api.upsert('friendships', friendshipRows(ids), 'id');
  await api.upsert('messages', messageRows(ids), 'id');
  await api.upsert('follows', followRows(ids), 'follower_id,following_id');
  await api.upsert('spotify_connections', await spotifyRows(ids), 'user_id');
  await api.upsert('notifications', notificationRows(ids), 'id');

  // Blocks are intentionally last: moderation triggers reject later messages
  // involving either side of a block.
  await api.upsert('blocked_users', [
    { blocker_id: ids.get('blocker'), blocked_id: ids.get('spotify_expired'), created_at: isoOffset({ days: -4 }) },
    { blocker_id: ids.get('spotify_expired'), blocked_id: ids.get('blocker'), created_at: isoOffset({ days: -4, minutes: 1 }) },
  ], 'blocker_id,blocked_id');

  console.log(`Seed completato: ${users.length} auth users, ${profiles.length} profili pubblici, 8 eventi.`);
  console.log(`Namespace: ${SEED_NAMESPACE}`);
  console.log(`Password comune: ${password}`);
  console.log('L’utente 09 resta intenzionalmente auth-only fino al primo avvio dell’app.');
}

function isOwnedSeedAuthUser(user) {
  const email = user.email?.toLowerCase() ?? '';
  const ownedEmail = email.startsWith(EMAIL_PREFIX) && email.endsWith(`@${EMAIL_DOMAIN}`);
  return ownedEmail && user.app_metadata?.seed_namespace === SEED_NAMESPACE;
}

async function clean(api) {
  // Direct messages use ON DELETE SET NULL for GDPR retention, so delete only
  // our namespaced messages before removing auth identities.
  const messageFilter = new URLSearchParams({
    'metadata->>seed_namespace': `eq.${SEED_NAMESPACE}`,
  }).toString();
  await api.rest('messages', { method: 'DELETE', query: messageFilter });

  const authUsers = await api.listAuthUsers();
  const owned = authUsers.filter(isOwnedSeedAuthUser);
  if (owned.length > 0) {
    const ids = owned.map((user) => user.id).join(',');
    const participantFilter = new URLSearchParams({
      or: `(sender_id.in.(${ids}),receiver_id.in.(${ids}))`,
    }).toString();
    await api.rest('messages', { method: 'DELETE', query: participantFilter });
  }
  for (const user of owned) await api.deleteAuthUser(user.id);

  const eventFilter = new URLSearchParams({
    external_id: `like.${EVENT_PREFIX}*`,
  }).toString();
  await api.rest('events', { method: 'DELETE', query: eventFilter });

  console.log(`Pulizia completata: ${owned.length} auth users e gli eventi ${EVENT_PREFIX}* rimossi.`);
}

function printFixtures(total = MIN_USERS) {
  const password = process.env.VIBRA_TEST_PASSWORD?.trim() || DEFAULT_PASSWORD;
  console.log(JSON.stringify({
    namespace: SEED_NAMESPACE,
    password,
    users: buildUsers(total).map((user) => ({
      scenario: user.key,
      description: user.scenario,
      email: emailFor(user),
      password,
    })),
  }, null, 2));
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  if (options.command === 'help') {
    usage();
    return;
  }
  if (options.command === 'fixtures') {
    printFixtures(options.users);
    return;
  }
  if (!['seed', 'reset', 'clean'].includes(options.command)) {
    fail(`Comando sconosciuto: ${options.command}`);
  }

  const target = assertSafeTarget(options);
  const destructive = options.command === 'reset' || options.command === 'clean' || options.reset;
  if (destructive && options.confirm !== RESET_CONFIRMATION) {
    fail(`Reset/clean richiede --confirm ${RESET_CONFIRMATION}`);
  }

  console.log(
    `Target verificato: ${target.environment} · ${target.url} · ${target.local ? 'locale' : 'remoto allowlisted'}`,
  );
  console.log(
    `Piano: ${options.command}${options.reset ? '+reset' : ''}, ${options.users} utenti, ${options.city} (${options.latitude}, ${options.longitude}).`,
  );
  if (options.dryRun) {
    console.log('Dry-run completato: nessuna chiamata di rete e nessuna modifica.');
    return;
  }

  const api = new SupabaseAdmin(target);
  await verifySchema(api);

  if (destructive) await clean(api);
  if (options.command !== 'clean') await seed(api, options);
}

main().catch((error) => {
  console.error(`ERRORE: ${error instanceof Error ? error.message : String(error)}`);
  process.exitCode = 1;
});
