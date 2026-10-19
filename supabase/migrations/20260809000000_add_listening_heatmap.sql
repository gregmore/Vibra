-- Migration: aggiunge la colonna listening_heatmap alla tabella music_profiles
-- La colonna memorizza la distribuzione degli ascolti per giorno della settimana
-- come array JSONB: [{day: "Lun", value: 0.8}, ..., {day: "Dom", value: 0.4}]

ALTER TABLE public.music_profiles
  ADD COLUMN IF NOT EXISTS listening_heatmap JSONB NOT NULL DEFAULT '[]'::jsonb;

COMMENT ON COLUMN public.music_profiles.listening_heatmap IS
  'Distribuzione normalizzata (0..1) degli ascolti recenti per giorno della settimana. Array di 7 oggetti {day: string, value: number}.';
