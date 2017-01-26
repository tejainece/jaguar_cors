part of jaguar_cors;

class CorsOptions {
  /// Allow all origins
  ///
  /// Under the hood:
  /// Sets 'Access-Control-Allow-Origin: *'
  final bool allowAllOrigins;

  /// The origins that are allowed
  ///
  /// Setting [allowAllOrigins] to [true] overrides [allowedOrigins]
  ///
  /// Example: ['http://example.com', 'http://hello.com']
  ///
  /// Under the hood:
  /// Sets Access-Control-Allow-Origin to list of allowed origins
  final List<String> allowedOrigins;

  /// Whether or not the app supports credentials.
  ///
  /// Under the hood:
  /// Sets Access-Control-Allow-Credentials
  final bool allowCredentials;

  /// Allow all methods
  ///
  /// Under the hood:
  /// Sets 'Access-Control-Allow-Methods: *'
  final bool allowAllMethods;

  /// The HTTP methods that are allowed
  ///
  /// Under the hood:
  /// Sets Access-Control-Allow-Methods
  final List<String> allowedMethods;

  /// Allow all headers
  ///
  /// Under the hood:
  /// Sets Access-Control-Allow-Headers
  final bool allowAllHeaders;

  /// The HTTP request headers that are allowed
  ///
  /// Under the hood:
  /// Sets Access-Control-Allow-Headers
  final List<String> allowedHeaders;

  /// Expose all headers
  ///
  /// Under the hood:
  /// Sets Access-Control-Allow-Headers
  final bool exposeAllHeaders;

  /// The HTTP request headers that are exposed
  ///
  /// Under the hood:
  /// Sets Access-Control-Allow-Headers
  final List<String> exposeHeaders;

  /// The maximum time (in seconds) to cache the preflight response
  ///
  /// Under the hood:
  /// Sets Access-Control-Max-Age
  final int maxAge;

  final bool vary;

  final allowNonCorsRequests;

  const CorsOptions(
      {this.allowAllOrigins: false,
      this.allowedOrigins: const [],
      this.allowCredentials: false,
      this.allowAllMethods: false,
      this.allowedMethods: const [],
      this.allowAllHeaders: false,
      this.allowedHeaders: const [],
      this.exposeAllHeaders: false,
      this.exposeHeaders: const [],
      this.maxAge,
      this.vary: false,
      this.allowNonCorsRequests: true});
}
