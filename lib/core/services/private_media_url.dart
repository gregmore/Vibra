/// Convert legacy chat URLs into a session-authenticated Storage request.
/// Never send the session token to a URL chosen by a message sender.
Uri? privateChatMediaUri(String value, String supabaseUrl) {
  final base = Uri.tryParse(supabaseUrl);
  final supplied = Uri.tryParse(value);
  if (base == null ||
      supplied == null ||
      base.scheme != 'https' ||
      !supplied.hasAuthority ||
      supplied.scheme != 'https' ||
      supplied.origin != base.origin ||
      supplied.userInfo.isNotEmpty) {
    return null;
  }
  final parts = supplied.pathSegments;
  if (parts.length != 7 ||
      parts.take(3).join('/') != 'storage/v1/object' ||
      !['sign', 'authenticated', 'public'].contains(parts[3]) ||
      parts[4] != 'chat-media') {
    return null;
  }
  if (!RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(parts[5]) ||
      !RegExp(r'^[0-9a-fA-F-]{36}\.png$').hasMatch(parts[6])) {
    return null;
  }
  return base.replace(
    pathSegments: [
      'storage',
      'v1',
      'object',
      'authenticated',
      'chat-media',
      parts[5],
      parts[6],
    ],
    query: '',
    fragment: '',
  );
}

/// Authenticated Storage URL of a story or feed photo. The path comes from
/// the story/post row and must be `<uuid>/<uuid>.png` (written by
/// upload-image); only the private story and feed buckets are allowed.
Uri? storyMediaUri(
  String? path,
  String supabaseUrl, {
  String bucket = 'story-media',
}) {
  final base = Uri.tryParse(supabaseUrl);
  if (path == null ||
      !const {'story-media', 'feed-media'}.contains(bucket) ||
      base == null ||
      base.scheme != 'https' ||
      !RegExp(r'^[0-9a-f-]{36}/[0-9a-f-]{36}\.png$').hasMatch(path)) {
    return null;
  }
  return base.replace(
    pathSegments: [
      'storage',
      'v1',
      'object',
      'authenticated',
      bucket,
      ...path.split('/'),
    ],
    query: '',
    fragment: '',
  );
}
