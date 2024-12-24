// scopes.dart

const List<String> scopes = [
  'alert:read',
  'alert:write',
  'attachment:read',
  'attachment:write',
  'conversation:read',
  'conversation:write',
  'media:read',
  'media:write',
  'media_category:read',
  'media_category:write',
  'node:read',
  'node:write',
  'profile_post:read',
  'profile_post:write',
  'thread:write',
  'thread:read',
  'user:read',
  'user:write',
];

/// Get all scopes as a single space-separated string
String getScopesAsString() {
  return scopes.join(' ');
}
