import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project/entities/message.dart';
import 'package:project/entities/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<List<User>?> getUsers() async {
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['CHAT_API_URL']}/user'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });

      if (response.statusCode != 200) {
        return null;
      } else {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<User> result = [];
        User user;
        for (var i = 0; i < jsonData.length; i++) {
          user =
              User(id: jsonData[i]['_id'], username: jsonData[i]['username']);
          result.add(user);
        }
        return result;
      }
    } catch (error) {
      return null;
    }
  }

  Future<List<Message>?> getPreviousMessagesByUserId(String id) async {
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['CHAT_API_URL']}/user/$id/previous-messages'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      if (response.statusCode != 200) {
        return null;
      } else {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<Message> result = [];
        Message message;
        for (var i = 0; i < jsonData.length; i++) {
          String userText = jsonData[i]['user'].trim();
          message = Message(
              text: userText,
              date: DateTime.parse(jsonData[i]['timestamp']),
              isSentByMe: true);
          result.add(message);
          String aiText = jsonData[i]['ai'].trim();
          message = Message(
              text: aiText,
              date: DateTime.parse(jsonData[i]['timestamp']),
              isSentByMe: false);
          result.add(message);
        }
        return result;
      }
    } catch (error) {
      return null;
    }
  }

  Future<String?> getUserCategory(String prompt) async {
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['CHAT_API_URL']}/user/categorize?prompt=$prompt'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      if (response.statusCode != 200) {
        return null;
      } else {
        final result = jsonDecode(response.body);
        return result;
      }
    } catch (error) {
      return null;
    }
  }
}
