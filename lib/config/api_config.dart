class ApiConfig {
  /// Base URL for API endpoints. Configurable globally.
  static String baseUrl = 'https://api.example.com';
  
  /// Reels Endpoint
  static const String reelsEndpoint = '/api/reels';
  
  /// Full Reels URL with pagination parameters
  static String reelsUrl({int page = 1, int limit = 10}) {
    return '$baseUrl$reelsEndpoint?page=$page&limit=$limit';
  }
}
