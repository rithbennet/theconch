import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://your-ngrok-url.ngrok.io'; // Replace with your actual ngrok URL

  static Future<Map<String, dynamic>> askClassicConch() async {
    final response = await http.get(Uri.parse('$baseUrl/classic'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get classic conch response');
    }
  }

  static Future<Map<String, dynamic>> askCulinaryOracle() async {
    final response = await http.get(Uri.parse('$baseUrl/culinary'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get culinary oracle response');
    }
  }

  static Future<Map<String, dynamic>> askAbyss(String question) async {
    final response = await http.post(
      Uri.parse('$baseUrl/abyss'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'question': question}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get abyss response');
    }
  }
}
