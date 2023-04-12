import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  Future<String?> askChatbot(String prompt) async {
    final response = await http.get(
        Uri.parse('${dotenv.env['CHAT_API_URL']}/ask?query="$prompt&id=user1"'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
    if (response.statusCode != 200) {
      return null;
    } else {
      return jsonDecode(response.body)['answer'];
    }
  }
}
