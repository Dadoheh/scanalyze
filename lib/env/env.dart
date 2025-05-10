class Env {
  static const String apiBaseUrl = "http://localhost:8000";
  
  static String get loginUrl => "$apiBaseUrl/login";
  static String get registerUrl => "$apiBaseUrl/register";
}

