BEGIN;
-- Only the decoding/transcoding backend may create or replace user images.
CREATE POLICY image_upload_requires_backend ON storage.objects
AS RESTRICTIVE FOR INSERT TO authenticated
WITH CHECK (bucket_id NOT IN ('avatars','chat-media'));
CREATE POLICY image_replace_requires_backend ON storage.objects
AS RESTRICTIVE FOR UPDATE TO authenticated
USING (bucket_id NOT IN ('avatars','chat-media'))
WITH CHECK (bucket_id NOT IN ('avatars','chat-media'));
COMMIT;
