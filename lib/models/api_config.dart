class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    required this.companyCode,
    required this.companyToken,
  });

  final String baseUrl;
  final String companyCode;
  final String companyToken;

  bool get isComplete =>
      baseUrl.isNotEmpty && companyCode.isNotEmpty && companyToken.isNotEmpty;

  bool get isValidUrl {
    final uri = Uri.tryParse(baseUrl);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  Uri buildUri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }
}
