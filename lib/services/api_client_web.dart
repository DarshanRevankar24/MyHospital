import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

http.Client getClient() {
  final client = BrowserClient();
  client.withCredentials = true; // Essential for CORS cookies
  return client;
}
