export function proximityScore(distanceKm: number): number {
  if (distanceKm <= 25) return 100;
  if (distanceKm >= 250) return 0;
  const slope = 100 / (250 - 25);
  return clamp(100 - ((distanceKm - 25) * slope), 0, 100);
}

export function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}
