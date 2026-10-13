class ApiConfig {
  // Celular físico na mesma rede Wi-Fi do PC:
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://143.106.241.20:8080/api',
  );
}
