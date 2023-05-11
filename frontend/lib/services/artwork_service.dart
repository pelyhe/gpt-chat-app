import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:project/entities/artwork.dart';

class ArtworkService {
  Future<List<Artwork>?> getArtworks() async {
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['CHAT_API_URL']}/artwork'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      if (response.statusCode != 200) {
        return null;
      } else {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<Artwork> result = [];
        Artwork artwork;
        for (var i = 0; i < jsonData.length; i++) {
          artwork = Artwork(
            id: jsonData[i]['_id'],
            title: jsonData[i]['title'],
            desc: jsonData[i]['description'],
            height: jsonData[i]['height'],
            technique: jsonData[i]['technique'],
            width: jsonData[i]['width'],
            year: jsonData[i]['year'],
            price: jsonData[i]['price'],
            artist: jsonData[i]['artist'],
            type: jsonData[i]['type'],
          );
          result.add(artwork);
        }
        return result;
      }
    } catch (error) {
      return null;
    }
  }
}
