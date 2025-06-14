import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://theconch.onrender.com/api';
  static const String audioBaseUrl = 'https://theconch.onrender.com';

  static Future<Map<String, dynamic>> askClassicConch() async {
    final response = await http.get(Uri.parse('$baseUrl/classic'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Map backend fields to frontend expectations
      return {
        'answer': data['message'],
        'audioUrl': data['audio_url'] != null && data['audio_url'].toString().startsWith('/')
            ? audioBaseUrl + data['audio_url']
            : data['audio_url'],
      };
    } else {
      throw Exception('Failed to get classic conch response');
    }
  }

  static Future<Map<String, dynamic>> askCulinaryOracle({String? constraint}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/what-to-eat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'constraint': constraint}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'answer': data['message'],
        'audioUrl': data['audio_url'] != null && data['audio_url'].toString().startsWith('/')
            ? audioBaseUrl + data['audio_url']
            : data['audio_url'],
      };
    } else {
      throw Exception('Failed to get culinary oracle response');
    }
  }

  static Future<Map<String, dynamic>> askAbyss(String question) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ask-anything'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'question': question}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'answer': data['message'],
        'audioUrl': data['audio_url'] != null && data['audio_url'].toString().startsWith('/')
            ? audioBaseUrl + data['audio_url']
            : data['audio_url'],
      };
    } else {
      throw Exception('Failed to get abyss response');
    }
  }
}
