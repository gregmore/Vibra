SET LOCAL ROLE postgres;
CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA extensions;
SELECT set_config('search_path', quote_ident(n.nspname) || ',public,extensions,pg_catalog', true)
FROM pg_extension e JOIN pg_namespace n ON n.oid = e.extnamespace
WHERE e.extname = 'pgtap';
-- pgTAP helpers are test-only privileges, rolled back with the fixtures.
DO $test_setup$
DECLARE f record; ns text;
BEGIN
  SELECT n.nspname INTO ns FROM pg_extension e JOIN pg_namespace n ON n.oid=e.extnamespace WHERE e.extname='pgtap';
  EXECUTE format('GRANT USAGE ON SCHEMA %I TO anon, authenticated', ns);
  FOR f IN SELECT p.oid::regprocedure AS signature FROM pg_proc p
    JOIN pg_depend d ON d.classid='pg_proc'::regclass AND d.objid=p.oid AND d.deptype='e'
    JOIN pg_extension e ON e.oid=d.refobjid WHERE e.extname='pgtap'
  LOOP
    EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO anon, authenticated', f.signature);
  END LOOP;
END;
$test_setup$;
-- Existing positive-path security fixtures exercise the opt-in integration.
-- Pause-specific tests switch it off within their own rolled-back transaction.
UPDATE public.launch_features SET enabled = true WHERE feature = 'spotify';
