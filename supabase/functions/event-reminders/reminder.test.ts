import { assertEquals } from 'https://deno.land/std@0.208.0/assert/mod.ts';
import { reminderDays, remindersEnabled } from './reminder.ts';

Deno.test('event reminders use Italian calendar days rather than rounding hours', () => {
  const now = new Date('2026-10-10T09:15:00Z');
  assertEquals(reminderDays('2026-10-10T21:00:00Z', now), 0);
  assertEquals(reminderDays('2026-10-11T21:00:00Z', now), 1);
  assertEquals(reminderDays('2026-10-17T21:00:00Z', now), 7);
  assertEquals(reminderDays('2026-10-12T21:00:00Z', now), null);
  assertEquals(reminderDays('2026-10-09T20:00:00Z', now), null);
  assertEquals(reminderDays('invalid', now), null);
});
Deno.test('calendar reminders survive DST and the UTC date boundary', () => {
  assertEquals(reminderDays('2026-10-25T20:00:00Z', new Date('2026-10-24T08:00:00Z')), 1);
  assertEquals(reminderDays('2026-10-10T23:30:00Z', new Date('2026-10-11T00:15:00Z')), 0);
});
Deno.test('both global consent and event category can disable reminders', () => {
  assertEquals(remindersEnabled({ push_enabled: false }), false);
  assertEquals(remindersEnabled({ push_enabled: true, push_settings: { event_alert: false } }), false);
  assertEquals(remindersEnabled({ push_enabled: true }), true);
});
