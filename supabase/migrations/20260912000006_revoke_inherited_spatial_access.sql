BEGIN;
-- PostGIS grants SELECT to PUBLIC; role-only revocation does not remove it.
REVOKE ALL ON TABLE public.spatial_ref_sys FROM PUBLIC;
GRANT SELECT ON TABLE public.spatial_ref_sys TO service_role;
COMMIT;
