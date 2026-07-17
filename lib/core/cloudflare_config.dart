// ==============================
// إعدادات Cloudflare AI
// ==============================

abstract class CloudflareConfig {
  static const String accountId = String.fromEnvironment('CF_ACCOUNT_ID');
  static const String apiToken = String.fromEnvironment('CF_API_TOKEN');
  static const String baseUrl = 'https://api.cloudflare.com/client/v4/accounts/$accountId/ai/run';
  static const String imageModel = '@cf/black-forest-labs/flux-1-schnell';
}
