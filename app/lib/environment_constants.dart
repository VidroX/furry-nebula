class EnvironmentConstants {
  static const String environmentType = String.fromEnvironment(
    'API_ENV',
    defaultValue: 'production',
  );

  static const String apiEndpoint = 'API_ENDPOINT';
}
