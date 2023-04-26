import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../entities/artist.dart';
import '../entities/gallery.dart';

class ArtistService {
  Future<List<Artist>?> getArtworks() async {
    try {
      final response = await http.get(
          //TODO make /artist endpoint
          Uri.parse('${dotenv.env['CHAT_API_URL']}/artist'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      if (response.statusCode != 200) {
        return null;
      } else {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<Artist> result = [];
        Artist artist;
        for (var i = 0; i < jsonData.length; i++) {
          artist = Artist(
            id: jsonData[i]['_id'],
            name: jsonData[i]['name'],
            country: jsonData[i]['country'],
          );
          result.add(artist);
        }
        return result;
      }
    } catch (error) {
      return null;
    }
  }
}
