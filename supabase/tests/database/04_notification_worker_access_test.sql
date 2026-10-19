BEGIN;
\ir ../pgtap_setup.inc
SELECT plan(3);

SELECT is(
  has_function_privilege('authenticated', 'vibra_private.enqueue_notification(text,jsonb)', 'EXECUTE'),
  false,
  'Clients cannot invoke privileged notification dispatch'
);
SELECT throws_ok(
  $$ SELECT vibra_private.enqueue_notification('delete-account', '{}'::jsonb) $$,
  '22023', 'Unknown notification worker',
  'Notification dispatch rejects unrelated workers'
);
SELECT is(
  has_function_privilege('authenticated', 'public.prepare_my_account_erasure()', 'EXECUTE'),
  false,
  'Legacy erasure remains unavailable to clients'
);

SELECT * FROM finish();
ROLLBACK;
