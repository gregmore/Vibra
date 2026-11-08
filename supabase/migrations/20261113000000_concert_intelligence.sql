-- VIBRA Concert Intelligence (docs/concert-intelligence.md).
--
-- Prices were stored without their currency and the app assumed EUR. A
-- price is only shown with the currency Ticketmaster published for it.
-- * New column events.price_currency (ISO 4217), written by the catalogue
--   sync from Ticketmaster priceRanges.
-- * Backfill: existing priced events in eurozone countries are EUR (the
--   local market currency Ticketmaster uses there). Everything else stays
--   NULL until the next sync refreshes it, and the app hides those prices.
BEGIN;

ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS price_currency text CHECK (price_currency ~ '^[A-Z]{3}$');

UPDATE public.events SET price_currency = 'EUR'
WHERE price_currency IS NULL AND (price_min IS NOT NULL OR price_max IS NOT NULL)
  AND country IN ('AT','BE','CY','DE','EE','ES','FI','FR','GR','HR','IE','IT','LT','LU','LV','MT','NL','PT','SI','SK');

CREATE INDEX IF NOT EXISTS events_upcoming_location_idx
  ON public.events (event_date, latitude, longitude) WHERE status IS DISTINCT FROM 'canceled';

NOTIFY pgrst, 'reload schema';
COMMIT;
