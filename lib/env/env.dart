class Env {
  static const String apiBaseUrl = "http://localhost:9091";

  // netsh interface portproxy add v4tov4 listenport=8000 listenaddress=0.0.0.0 connectport=8000 connectaddress=$(wsl hostname -I | awk '{print $1}')
  // netsh interface portproxy add v4tov4 listenport=8000 listenaddress=0.0.0.0 connectport=8000 connectaddress=192.168.1.19
  static String get loginUrl => "$apiBaseUrl/login";
  static String get registerUrl => "$apiBaseUrl/register";
}

