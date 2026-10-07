// Retired: ordinary users must never trigger privileged account seeding.
// Use script/seed_test_data.mjs against an explicitly isolated test project.
Deno.serve(() => new Response(JSON.stringify({ error: "endpoint_retired" }), {
  status: 410, headers: { "Content-Type": "application/json" },
}));
