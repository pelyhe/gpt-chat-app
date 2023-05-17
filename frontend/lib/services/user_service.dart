import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project/entities/message.dart';
import 'package:project/entities/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  //TODO refactor, data template changed
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
          user = User(
              id: jsonData[i]['_id'],
              username: jsonData[i]['username'],
              country: jsonData[i]['location'],
              isVIP: jsonData[i]['isVip'],
              auctions: jsonData[i]['goAuctions'],
              fairs: jsonData[i]['goArtfairs']);
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
          message = Message(
              text: jsonData[i]['user'],
              date: DateTime.parse(jsonData[i]['timestamp']),
              isSentByMe: true);
          result.add(message);
          message = Message(
              text: jsonData[i]['ai'],
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

  Future<http.Response> updateUser(User u) async {
    Map<String, dynamic> data = {
        'id': u.id,
        'username': u.username,
        'location': u.country,
        'favArtwork': u.favArtwork.toList(),
        'favGallery': u.favGallery.toList(),
        'favArtist': u.favArtist.toList(),
        'goAuctions': u.auctions,
        'goArtfairs': u.fairs,
        'isVip': u.isVIP,
    };
    return http.post(
      Uri.parse('${dotenv.env['CHAT_API_URL']}/user/update'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(data)
    );
  }
}
