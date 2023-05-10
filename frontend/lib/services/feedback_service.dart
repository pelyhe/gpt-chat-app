import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../entities/fb.dart';

class FeedbackService {
  Future<http.Response> upload(Fb fb) async {
    return http.post(
      Uri.parse('${dotenv.env['CHAT_API_URL']}/uploadFeedback'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ai': fb.text,
        'feedback':fb.feedback,
        'opinion': fb.opinion.toString(),
        'date': fb.date.toString()
      }),
    );
  }
}
