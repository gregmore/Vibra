type Artist = { id?: string; genres?: unknown };

export class SpotifyRequestError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

function normalizeGenres(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return [...new Set(value
    .filter((genre): genre is string => typeof genre === "string")
    .map((genre) => genre.trim().toLowerCase())
    .filter(Boolean))];
}

// Keep genres already supplied for every artist and hydrate only missing ones.
// Individual artist requests also work where Spotify's bulk endpoint is disabled.
export async function loadTopGenres(
  artists: Artist[],
  getArtist: (id: string) => Promise<Artist>,
) {
  const counts = new Map<string, number>();
  const seen = new Set<string>();
  let canFetch = true;

  for (const artist of artists) {
    if (artist.id && seen.has(artist.id)) continue;
    if (artist.id) seen.add(artist.id);
    let genres = normalizeGenres(artist.genres);
    if (genres.length === 0 && artist.id && canFetch) {
      try {
        genres = normalizeGenres((await getArtist(artist.id)).genres);
      } catch (error) {
        // Stop repeated requests after an access or rate-limit failure, while
        // still counting genres already present on the remaining artists.
        if (error instanceof SpotifyRequestError &&
            [401, 403, 429].includes(error.status)) {
          canFetch = false;
        }
        console.warn("Artist genres unavailable", artist.id, error);
      }
    }
    for (const genre of genres) {
      counts.set(genre, (counts.get(genre) ?? 0) + 1);
    }
  }

  const sorted = [...counts].sort((a, b) =>
    b[1] - a[1] || a[0].localeCompare(b[0])
  );
  const max = sorted[0]?.[1] ?? 1;
  return sorted.map(([genre, count]) => ({
    genre,
    weight: Number((count / max).toFixed(4)),
  }));
}
