class ApiConfig {
  // Backend API Base URL
  // For Android Emulator: use 10.0.2.2 instead of localhost
  // For iOS Simulator: use localhost
  // For Real Device: use your computer's IP address (e.g., 192.168.1.x)
  static const String baseUrl = 'http://10.0.2.2:3000';

  // NewsAPI Configuration (SubCPMK 2)
  static const String newsApiKey = '8a199d5809834ea99c959640de78fdf5';
  static const String newsApiUrl = 'https://newsapi.org/v2/everything';

  // API Endpoints
  static const String authEndpoint = '$baseUrl/api/auth';
  static const String usersEndpoint = '$baseUrl/api/users';
  static const String wasteTypesEndpoint = '$baseUrl/api/waste-types';
  static const String transactionsEndpoint = '$baseUrl/api/transactions';
}
