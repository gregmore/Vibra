const calendar = new Intl.DateTimeFormat('en-GB', {
  timeZone: 'Europe/Rome', year: 'numeric', month: '2-digit', day: '2-digit',
});
function calendarDay(date: Date): number {
  const parts = calendar.formatToParts(date);
  const value = (type: string) => Number(parts.find((part) => part.type === type)?.value);
  return Date.UTC(value('year'), value('month') - 1, value('day')) / 86400000;
}

export function reminderDays(eventDate: string, now: Date): number | null {
  const date = new Date(eventDate);
  if (!Number.isFinite(date.getTime())) return null;
  const days = calendarDay(date) - calendarDay(now);
  return [0, 1, 7].includes(days) ? days : null;
}

export function remindersEnabled(user: {
  push_enabled?: boolean | null;
  push_settings?: Record<string, boolean> | null;
}): boolean {
  return user.push_enabled !== false && user.push_settings?.event_alert !== false;
}
