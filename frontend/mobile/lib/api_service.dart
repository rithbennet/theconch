import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://theconch.onrender.com/api';
  static const String audioBaseUrl = 'https://theconch.onrender.com';
  static Future<Map<String, dynamic>> askClassicConch({String voice = 'british_lady', String? question}) async {
    final Map<String, dynamic> requestBody = {'voice': voice};
    if (question != null && question.isNotEmpty) {
      requestBody['question'] = question;
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/classic'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
    print('DEBUG: response.body = \\${response.body}');
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
      throw Exception('Failed to get classic conch response: \\${response.body}');
    }
  }
  static Future<Map<String, dynamic>> askCulinaryOracle({String? constraint, String? voiceQuestion}) async {
    final Map<String, dynamic> requestBody = {};
    if (constraint != null && constraint.isNotEmpty) {
      requestBody['constraint'] = constraint;
    }
    if (voiceQuestion != null && voiceQuestion.isNotEmpty) {
      requestBody['voice_question'] = voiceQuestion;
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/what-to-eat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
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
