import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";
import { createSupabaseServiceClient } from "../_shared/supabase.ts";
import { corsHeaders } from "../_shared/cors.ts";

const MOCK_NAMES = [
  "Alessia", "Marco", "Giulia", "Andrea", "Sofia", "Lorenzo", 
  "Martina", "Matteo", "Chiara", "Alessandro", "Francesca", "Luca",
  "Elisa", "Davide", "Sara", "Simone", "Elena", "Federico", "Silvia", "Gabriele"
];

const MOCK_SURNAMES = [
  "Rossi", "Russo", "Ferrari", "Esposito", "Bianchi", "Romano", "Colombo", "Ricci",
  "Marino", "Greco", "Bruno", "Gallo", "Conti", "De Luca", "Mancini", "Costa"
];

const MOCK_AVATARS = [
  "https://i.pravatar.cc/150?img=1",
  "https://i.pravatar.cc/150?img=2",
  "https://i.pravatar.cc/150?img=3",
  "https://i.pravatar.cc/150?img=4",
  "https://i.pravatar.cc/150?img=5",
  "https://i.pravatar.cc/150?img=10",
  "https://i.pravatar.cc/150?img=11",
  "https://i.pravatar.cc/150?img=12",
  "https://i.pravatar.cc/150?img=20",
  "https://i.pravatar.cc/150?img=21",
];

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization')!;
    if (!authHeader) {
        throw new Error('No authorization header');
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    );
    
    // Get current user
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser();
    if (userError || !user) throw new Error('Error authenticating user');

    const adminClient = createSupabaseServiceClient();

    // 1. Get current user's music profile
    const { data: profile, error: profileError } = await adminClient
        .from('music_profiles')
        .select('top_artists, top_genres, top_tracks')
        .eq('user_id', user.id)
        .single();
        
    if (profileError || !profile || !profile.top_artists || profile.top_artists.length === 0) {
        throw new Error('Il tuo profilo musicale non ha artisti. Collega Spotify e sincronizza prima!');
    }

    const myArtists = profile.top_artists as any[];
    
    const N_USERS = 20;
    const generatedUsers = [];

    for (let i = 0; i < N_USERS; i++) {
      const name = MOCK_NAMES[Math.floor(Math.random() * MOCK_NAMES.length)];
      const surname = MOCK_SURNAMES[Math.floor(Math.random() * MOCK_SURNAMES.length)];
      const email = `mock_${crypto.randomUUID().substring(0, 8)}@vibra.com`;
      const password = 'Password123!';
      const avatar = MOCK_AVATARS[Math.floor(Math.random() * MOCK_AVATARS.length)];
      
      // Select 40% to 90% of user's artists
      const percentage = 0.4 + (Math.random() * 0.5);
      const numArtists = Math.floor(myArtists.length * percentage) || 1;
      
      const shuffledArtists = [...myArtists].sort(() => 0.5 - Math.random());
      const mockArtists = shuffledArtists.slice(0, numArtists);

      // 2. Create Auth User
      const { data: authData, error: authError } = await adminClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
      });

      if (authError || !authData.user) {
        console.error("Error creating auth user:", authError);
        continue;
      }
      
      const newUserId = authData.user.id;

      // 3. Create Public Profile
      await adminClient.from('users').insert({
        id: newUserId,
        email: email,
        username: `${name.toLowerCase()}_${surname.toLowerCase()}_${Math.floor(Math.random() * 10000)}`,
        display_name: `${name} ${surname}`,
        avatar_url: avatar,
        bio: "Appassionat* di musica dal vivo! 🎉 Aggiunto automaticamente per test.",
        last_latitude: 45.4642 + (Math.random() - 0.5) * 0.1, // Milano area
        last_longitude: 9.1900 + (Math.random() - 0.5) * 0.1,
      });

      // 4. Create Music Profile
      await adminClient.from('music_profiles').insert({
        user_id: newUserId,
        top_artists: mockArtists,
        top_genres: profile.top_genres || [],
        top_tracks: profile.top_tracks || [],
        is_public: true
      });
      
      // 5. Create Match
      const compatibility = percentage * 100;
      const [user_id_a, user_id_b] = user.id < newUserId 
        ? [user.id, newUserId] 
        : [newUserId, user.id];

      await adminClient.from('user_matches').insert({
        user_id_a,
        user_id_b,
        compatibility: Math.min(Math.round(compatibility), 100),
        shared_artists: numArtists,
        shared_genres: 0, // mock
      });
      
      generatedUsers.push(newUserId);
    }

    return new Response(JSON.stringify({ 
      success: true, 
      message: `Creati ${generatedUsers.length} utenti compatibili! Torna nell'app e fai Sincronizza per vederli.`
    }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
