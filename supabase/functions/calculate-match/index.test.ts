import { assertEquals } from "https://deno.land/std@0.208.0/assert/mod.ts";
import { clamp } from "../_shared/geo.ts";

// Abbiamo estratto la logica core della formula in una funzione pura
// per poterla testare indipendentemente dai side-effects di Supabase e HTTP.
export function calculateMatchScore(
  sharedArtists: number
): number {
  const topArtistsDen = 50;
  return clamp((sharedArtists / topArtistsDen) * 100, 0, 100);
}

Deno.test("Calculate Match - Caso limite 1: 50 artisti condivisi", () => {
  const sharedArtists = 50;
  const score = calculateMatchScore(sharedArtists);
  
  // (50/50)*100 = 100
  assertEquals(Math.round(score), 100);
});

Deno.test("Calculate Match - Caso limite 2: 0 artisti in comune", () => {
  const sharedArtists = 0;
  const score = calculateMatchScore(sharedArtists);
  
  // (0/50)*100 = 0
  assertEquals(Math.round(score), 0);
});

Deno.test("Calculate Match - Caso ibrido: 25 artisti condivisi", () => {
  const sharedArtists = 25;
  const score = calculateMatchScore(sharedArtists);
  
  // Artists: (25/50)*100 = 50
  assertEquals(Math.round(score), 50);
});
