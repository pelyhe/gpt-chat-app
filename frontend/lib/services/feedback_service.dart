import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FeedbackService {
  Future<http.Response> upload(String type, String feedback) async {
    
    return http.post(
      Uri.parse('${dotenv.env['CHAT_API_URL']}/valami'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'type': type,
        'feedback':feedback,
      }),
    );
  }
}
