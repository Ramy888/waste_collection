class AppConstants {
  static const String appName = 'Waste Collection';
  static const String baseUrl = 'https://api.wastecollection.com'; // Example URL
  static const String termsUrl = 'https://wastecollection.com/terms';
  static const String privacyUrl = 'https://wastecollection.com/privacy';
  static const String supportEmail = 'support@wastecollection.com';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';

  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String unauthorizedError = 'Unauthorized access';
}